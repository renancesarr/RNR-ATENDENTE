#!/usr/bin/env python3
"""Verifica status da sessão Evolution API."""

import argparse
import json
import os
import sys
import urllib.error
import urllib.request


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


def main() -> int:
    parser = argparse.ArgumentParser(description="Valida sessão ativa na Evolution API")
    parser.add_argument("--instance", required=True, help="Nome da instância")
    parser.add_argument("--env", default=".env", help="Arquivo .env (default: ./.env)")
    parser.add_argument("--base-url", help="URL base (default: http://localhost:<porta>)")
    parser.add_argument("--expect", choices=["connected", "disconnected"], default="connected",
                        help="Estado esperado da sessão")
    args = parser.parse_args()

    env = load_env(args.env)
    port = env.get("EVOLUTION_API_HTTP_PORT", "8088")
    token = env.get("AUTHENTICATION_API_KEY", env.get("EVOLUTION_AUTH_KEY", ""))
    if not token:
        print("AUTHENTICATION_API_KEY não encontrado", file=sys.stderr)
        return 1

    base_url = args.base_url or f"http://localhost:{port}"
    url = f"{base_url}/instances/{args.instance}/status"

    req = urllib.request.Request(url, headers={"Authorization": f"Bearer {token}"})
    try:
        with urllib.request.urlopen(req) as resp:  # type: ignore[arg-type]
            payload = json.load(resp)
    except urllib.error.HTTPError as exc:  # type: ignore[attr-defined]
        print(f"Erro ao consultar status ({exc.code}): {exc.read().decode()}", file=sys.stderr)
        return 1

    print(json.dumps(payload, indent=2, ensure_ascii=False))

    status = payload.get("connectionStatus") or payload.get("state") or payload.get("status")
    if status is None:
        print("Campo de status não encontrado na resposta", file=sys.stderr)
        return 1

    status_lower = str(status).lower()
    expect_lower = args.expect.lower()
    is_connected = status_lower in ("connected", "open", "authenticated")

    if expect_lower == "connected" and not is_connected:
        print(f"Sessão não está ativa (status={status})", file=sys.stderr)
        return 2
    if expect_lower == "disconnected" and is_connected:
        print(f"Sessão está ativa, mas o esperado era desconectada (status={status})", file=sys.stderr)
        return 3

    print(f"Sessão está de acordo com o esperado ({status}).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
