#!/usr/bin/env python3
"""CLI para ingerir documentos no esquema RAG."""

import argparse
import hashlib
import json
import os
import subprocess
import sys
import textwrap
import urllib.request
import urllib.error


def load_env(path: str) -> dict:
    data = {}
    if not os.path.exists(path):
        return data
    with open(path, "r", encoding="utf-8") as fh:
        for line in fh:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            if "=" not in line:
                continue
            key, value = line.split("=", 1)
            data[key] = value
    return data


def psql_literal(value: str | None) -> str:
    if value is None:
        return "NULL"
    return "'" + value.replace("'", "''") + "'"


def run_psql(sql: str, superuser: str, database: str, capture: bool = False) -> list[str] | None:
    base_cmd = [
        "docker",
        "compose",
        "exec",
        "-T",
        "postgres",
        "psql",
        "-v",
        "ON_ERROR_STOP=1",
        "-U",
        superuser,
        "-d",
        database,
    ]
    if capture:
        cmd = base_cmd + ["-At", "-F,", "-c", sql]
        result = subprocess.run(cmd, check=True, capture_output=True, text=True)
        output = [line.strip() for line in result.stdout.splitlines() if line.strip()]
        return output
    else:
        subprocess.run(base_cmd + ["-c", sql], check=True)
        return None


def chunk_text(text: str, chunk_size: int, overlap: int) -> list[str]:
    words = text.split()
    chunks = []
    start = 0
    while start < len(words):
        end = min(len(words), start + chunk_size)
        chunk = " ".join(words[start:end])
        chunks.append(chunk)
        start = end - overlap
        if start < 0:
            start = 0
    return chunks


def request_embedding(api_key: str, model: str, text_value: str) -> list[float]:
    payload = json.dumps({"input": text_value, "model": model}).encode("utf-8")
    req = urllib.request.Request(
        "https://api.openai.com/v1/embeddings",
        data=payload,
        method="POST",
        headers={
            "Content-Type": "application/json",
            "Authorization": f"Bearer {api_key}",
        },
    )
    with urllib.request.urlopen(req) as resp:  # type: ignore[arg-type]
        data = json.load(resp)
        return data["data"][0]["embedding"]


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Ingestão de documentos no esquema RAG",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=textwrap.dedent(
            """
            Exemplos:
              ./tools/rag-ingest-cli.py --file docs/readme.md --source-name "Manual MVP"
              ./tools/rag-ingest-cli.py --file faq.txt --skip-embedding  # usa vetor nulo
            """
        ),
    )
    parser.add_argument("--file", required=True, help="Arquivo de texto/markdown a ingerir")
    parser.add_argument("--source-name", required=True, help="Nome da fonte (rag_sources.name)")
    parser.add_argument("--source-type", default="document", help="Tipo da fonte (default: document)")
    parser.add_argument("--description", default="", help="Descrição opcional da fonte")
    parser.add_argument("--language", default="pt-BR", help="Idioma do documento")
    parser.add_argument("--chunk-size", type=int, default=500, help="Tamanho do chunk em palavras")
    parser.add_argument("--chunk-overlap", type=int, default=50, help="Overlap de palavras entre chunks")
    parser.add_argument("--model", default="text-embedding-3-small", help="Modelo de embeddings")
    parser.add_argument("--env", default=".env", help="Arquivo .env (default: ./ .env)")
    parser.add_argument("--skip-embedding", action="store_true", help="Não chama API, usa vetor nulo")

    args = parser.parse_args()

    if not os.path.exists(args.file):
        print(f"arquivo '{args.file}' não encontrado", file=sys.stderr)
        return 1

    env_data = load_env(args.env)

    superuser = env_data.get("POSTGRES_SUPERUSER", "postgres")
    database = env_data.get("POSTGRES_SUPERUSER_DB", "postgres")
    api_key = env_data.get("OPENAI_API_KEY", "")

    if not args.skip_embedding and not api_key:
        print("OPENAI_API_KEY não definido; use --skip-embedding ou configure a variável.", file=sys.stderr)
        return 1

    with open(args.file, "r", encoding="utf-8") as fh:
        text = fh.read()

    checksum = hashlib.sha256(text.encode("utf-8")).hexdigest()

    # Upsert source
    sql_source = f"""
        INSERT INTO rag_sources (name, source_type, description, metadata)
        VALUES ({psql_literal(args.source_name)}, {psql_literal(args.source_type)},
                {psql_literal(args.description)}, '{{}}'::jsonb)
        ON CONFLICT (name) DO UPDATE SET description = EXCLUDED.description, updated_at = now()
        RETURNING id;
    """
    source_rows = run_psql(sql_source, superuser, database, capture=True)
    source_id = source_rows[0] if source_rows else None

    if not source_id:
        print("Falha ao obter rag_source.id", file=sys.stderr)
        return 1

    # Upsert document
    sql_document = f"""
        INSERT INTO rag_documents (source_id, external_id, title, content, language, checksum, metadata)
        VALUES ({psql_literal(source_id)}, NULL, {psql_literal(os.path.basename(args.file))},
                {psql_literal(text)}, {psql_literal(args.language)}, {psql_literal(checksum)}, '{{}}'::jsonb)
        ON CONFLICT (checksum) DO UPDATE SET
            source_id = EXCLUDED.source_id,
            title = EXCLUDED.title,
            content = EXCLUDED.content,
            language = EXCLUDED.language,
            updated_at = now()
        RETURNING id;
    """
    document_rows = run_psql(sql_document, superuser, database, capture=True)
    document_id = document_rows[0] if document_rows else None

    if not document_id:
        print("Falha ao obter rag_documents.id", file=sys.stderr)
        return 1

    chunks = chunk_text(text, args.chunk_size, args.chunk_overlap)
    print(f"Gerando {len(chunks)} chunks...")

    for idx, chunk in enumerate(chunks):
        if args.skip_embedding:
            embedding = [0.0] * 1536
        else:
            try:
                embedding = request_embedding(api_key, args.model, chunk)
            except urllib.error.HTTPError as exc:  # type: ignore[attr-defined]
                print(f"Erro ao gerar embedding: {exc.read().decode()}", file=sys.stderr)
                return 1
        embedding_sql = "'[" + ",".join(f"{x:.8f}" for x in embedding) + "]'::vector"
        meta_json = json.dumps({"model": args.model})
        sql_embedding = f"""
            INSERT INTO rag_embeddings (document_id, chunk_index, embedding, chunk, metadata)
            VALUES ({psql_literal(document_id)}, {idx}, {embedding_sql},
                    {psql_literal(chunk)}, {psql_literal(meta_json)})
            ON CONFLICT (document_id, chunk_index) DO UPDATE SET
                embedding = EXCLUDED.embedding,
                chunk = EXCLUDED.chunk,
                metadata = EXCLUDED.metadata,
                updated_at = now();
        """
        run_psql(sql_embedding, superuser, database)

    print("Ingestão concluída com sucesso.")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except subprocess.CalledProcessError as exc:
        print(f"Erro ao executar psql: {exc}", file=sys.stderr)
        sys.exit(exc.returncode)
