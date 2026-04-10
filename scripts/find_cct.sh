#!/usr/bin/env bash
set -euo pipefail

if [[ -n "${CCT_BIN:-}" ]]; then
  if [[ -x "${CCT_BIN}" ]]; then
    printf '%s\n' "${CCT_BIN}"
    exit 0
  fi
  if command -v "${CCT_BIN}" >/dev/null 2>&1; then
    command -v "${CCT_BIN}"
    exit 0
  fi
  printf 'Civitas requires CCT via CCT_BIN or PATH; failed to resolve "%s".\n' "${CCT_BIN}" >&2
  exit 2
fi

for candidate in cct-host cct; do
  if command -v "${candidate}" >/dev/null 2>&1; then
    command -v "${candidate}"
    exit 0
  fi
done

printf 'Civitas requires an installed CCT compiler. Set CCT_BIN or add cct-host/cct to PATH.\n' >&2
exit 2
