SET search_path TO public;

WITH vec AS (
  SELECT
    '[' || string_agg(CASE WHEN i = 1 THEN '1' ELSE '0' END, ',') || ']' AS v_doc_a,
    '[' || string_agg(CASE WHEN i = 2 THEN '1' ELSE '0' END, ',') || ']' AS v_doc_b,
    '[' || string_agg(CASE WHEN i IN (1,2) THEN '0.9' ELSE '0' END, ',') || ']' AS v_query
  FROM generate_series(1, 1536) i
), src AS (
  INSERT INTO rag_sources (name, source_type, description, metadata)
  VALUES ('Test Semantic Source', 'test', 'Fonte temporária para testes', '{"test": true}'::jsonb)
  ON CONFLICT (name) DO UPDATE SET updated_at = now()
  RETURNING id
), docs AS (
  INSERT INTO rag_documents (source_id, external_id, title, content, language, checksum, metadata)
  SELECT src.id, 'doc-a', 'Documento A', 'conteúdo A', 'pt-BR', 'checksum-doc-a', '{"test": true}'::jsonb FROM src
  UNION ALL
  SELECT src.id, 'doc-b', 'Documento B', 'conteúdo B', 'pt-BR', 'checksum-doc-b', '{"test": true}'::jsonb FROM src
  ON CONFLICT (checksum) DO UPDATE SET updated_at = now()
  RETURNING id, external_id
), doc_ids AS (
  SELECT
    max(CASE WHEN external_id = 'doc-a' THEN id END) AS doc_a,
    max(CASE WHEN external_id = 'doc-b' THEN id END) AS doc_b
  FROM docs
), upsert_embeddings AS (
  INSERT INTO rag_embeddings (document_id, chunk_index, embedding, chunk, metadata)
  SELECT doc_ids.doc_a, 0, (vec.v_doc_a || '')::vector, 'chunk A', '{"test": true}'::jsonb FROM doc_ids, vec
  UNION ALL
  SELECT doc_ids.doc_b, 0, (vec.v_doc_b || '')::vector, 'chunk B', '{"test": true}'::jsonb FROM doc_ids, vec
  ON CONFLICT (document_id, chunk_index) DO UPDATE SET embedding = EXCLUDED.embedding, metadata = EXCLUDED.metadata
)
SELECT 1;

DO $$
DECLARE
  v_title text;
BEGIN
  SELECT d.title
  INTO v_title
  FROM rag_embeddings e
  JOIN rag_documents d ON d.id = e.document_id
  JOIN LATERAL (
    SELECT '[' || string_agg(CASE WHEN i IN (1,2) THEN '0.9' ELSE '0' END, ',') || ']' AS query_vec
    FROM generate_series(1, 1536) i
  ) q ON TRUE
  ORDER BY e.embedding <-> (q.query_vec || '')::vector
  LIMIT 1;

  IF v_title <> 'Documento A' THEN
    RAISE EXCEPTION 'Busca semântica retornou %, esperado Documento A', v_title;
  END IF;
END;
$$;

-- Limpeza dos registros de teste
WITH doc_ids AS (
  SELECT id FROM rag_documents WHERE metadata ->> 'test' = 'true'
)
DELETE FROM rag_embeddings WHERE document_id IN (SELECT id FROM doc_ids);

DELETE FROM rag_documents WHERE metadata ->> 'test' = 'true';

DELETE FROM rag_sources WHERE metadata ->> 'test' = 'true';
