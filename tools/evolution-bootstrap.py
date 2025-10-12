#!/usr/bin/env python3
"""CLI para criar instância na Evolution API e obter QR Code."""

import argparse
import base64
import json
import os
import sys
import time
import urllib.error
import urllib.request
from typing import Any


def load_env(path: str) -> dict[str, str]:
    data: dict[str, str] = {}
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


def request(method: str, url: str, token: str, payload: dict[str, Any] | None = None) -> Any:
    data = None
    headers = {"Authorization": f"Bearer {token}"}
    if payload is not None:
        data = json.dumps(payload).encode("utf-8")
        headers["Content-Type"] = "application/json"
    req = urllib.request.Request(url, data=data, method=method, headers=headers)
    with urllib.request.urlopen(req) as resp:  # type: ignore[arg-type]
        content = resp.read().decode("utf-8")
        if not content:
            return None
        return json.loads(content)


def main() -> int:
    parser = argparse.ArgumentParser(description="Bootstrap Evolution API instance")
    parser.add_argument("--instance", required=True, help="Nome da instância")
    parser.add_argument("--env", default=".env", help="Arquivo .env (default: ./.env)")
    parser.add_argument("--base-url", help="URL base da Evolution API (default: http://localhost:<port>)")
    parser.add_argument("--poll-seconds", type=int, default=5, help="Intervalo entre polls do QR code")
    parser.add_argument("--max-attempts", type=int, default=12, help="Número máximo de polls (default 12 ≈ 1min)")
    parser.add_argument("--qr-output", help="Arquivo para salvar QR em base64 decodificado (png)")
    parser.add_argument("--cid", default="default", help="Client ID opcional")
    parser.add_argument("--print-only", action="store_true", help="Apenas exibe payloads sem chamar API")

    args = parser.parse_args()

    env = load_env(args.env)
    port = env.get("EVOLUTION_API_HTTP_PORT", "8088")
    token = env.get("AUTHENTICATION_API_KEY", env.get("EVOLUTION_AUTH_KEY", ""))
    if not token:
        print("AUTHENTICATION_API_KEY não encontrado no ambiente", file=sys.stderr)
        return 1

    base_url = args.base_url or f"http://localhost:{port}"
    instance = args.instance

    create_payload = {
        "instanceName": instance,
        "description": f"Instância criada via CLI ({args.cid})",
        "cid": args.cid,
        "token": token,
        "qrcode": {"generate": True, "base64": True},
    }

    if args.print_only:
        print("POST", f"{base_url}/instances/create")
        print(json.dumps(create_payload, indent=2, ensure_ascii=False))
        return 0

    try:
        resp = request("POST", f"{base_url}/instances/create", token, create_payload)
    except urllib.error.HTTPError as exc:  # type: ignore[attr-defined]
        error_body = exc.read().decode()
        print(f"Erro ao criar instância ({exc.code}): {error_body}", file=sys.stderr)
        return 1

    if resp is None:
        print("Resposta inesperada ao criar instância", file=sys.stderr)
        return 1

    print("Instância solicitada:", json.dumps(resp, indent=2, ensure_ascii=False))

    qr_data = resp.get("qrcode") if isinstance(resp, dict) else None
    attempts = 0
    while qr_data is None and attempts < args.max_attempts:
        time.sleep(args.poll_seconds)
        attempts += 1
        try:
            qr_resp = request("GET", f"{base_url}/instances/{instance}/qrcode", token)
            if isinstance(qr_resp, dict) and qr_resp.get("base64"):
                qr_data = qr_resp["base64"]
                break
        except urllib.error.HTTPError as exc:  # type: ignore[attr-defined]
            print(f"Erro ao consultar QR ({exc.code}): {exc.read().decode()}", file=sys.stderr)
            return 1

    if not qr_data:
        print("Não foi possível obter QR code no tempo limite", file=sys.stderr)
        return 1

    print("QR Code (base64):")
    print(qr_data)

    if args.qr_output:
        try:
            with open(args.qr_output, "wb") as fh:
                fh.write(base64.b64decode(qr_data))
            print(f"QR salvo em {args.qr_output}")
        except Exception as exc:  # pylint: disable=broad-except
            print(f"Não foi possível salvar QR: {exc}", file=sys.stderr)

    return 0


if __name__ == "__main__":
    sys.exit(main())
