#!/usr/bin/env bash

set -euo pipefail

if ! command -v git >/dev/null 2>&1; then
  echo "validate-ia-change: git command not found" >&2
  exit 1
fi

staged_files="$(git diff --name-only --cached || true)"
if [[ -z "${staged_files}" ]]; then
  staged_files="$(git diff --name-only || true)"
fi

if [[ -z "${staged_files}" ]]; then
  base_ref="$(git merge-base HEAD origin/main 2>/dev/null || git rev-parse HEAD^ 2>/dev/null || echo "")"
  if [[ -n "${base_ref}" ]]; then
    staged_files="$(git diff --name-only "${base_ref}" HEAD || true)"
  fi
fi

if [[ -z "${staged_files}" ]]; then
  echo "validate-ia-change: nenhum arquivo modificado identificado."
  exit 0
fi

ia_reports="$(printf "%s" "${staged_files}" | grep -E '^docs/application-developer/[0-9]+-ia-code\.md$' || true)"

if [[ -z "${ia_reports}" ]]; then
  echo "validate-ia-change: falta arquivo docs/application-developer/<timestamp>-ia-code.md para esta alteração." >&2
  exit 2
fi

required_sections=(
  "## 1. Contexto consumido"
  "## 2. Objetivo da alteração"
  "## 3. Decisões e justificativas"
  "## 4. Implementação"
  "## 5. Pontos que precisam de revisão humana"
  "## 6. Follow-ups recomendados"
)

while IFS= read -r report; do
  for section in "${required_sections[@]}"; do
    if ! grep -Fq "${section}" "${report}"; then
      echo "validate-ia-change: seção obrigatória \"${section}\" ausente em ${report}" >&2
      exit 3
    fi
  done
done <<<"${ia_reports}"

echo "validate-ia-change: verificação concluída com sucesso."
