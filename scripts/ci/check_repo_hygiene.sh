#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../.."

blocked_paths='^(\.cct/|\.civitas-pid$|\.idea/|dist/|bin/cct-template-compile$|src/main$|tests/tmp/|tests/\.runner/|examples/.*/main$|examples/.*/dist/|examples/mural/var/|examples/mural/tests/tmp/|examples/mural_expandido/var/|examples/rede_social/data/|examples/rede_social/\.civitas/)'

if git ls-files | rg -n "${blocked_paths}" >/tmp/civitas_hygiene_paths.txt; then
  echo "Tracked runtime or generated artifacts are still present:"
  cat /tmp/civitas_hygiene_paths.txt
  exit 1
fi

if rg -n '/Users/|/home/' README.md docs examples .github >/tmp/civitas_hygiene_paths_abs.txt; then
  echo "Absolute local paths are still present in public docs:"
  cat /tmp/civitas_hygiene_paths_abs.txt
  exit 1
fi

echo "Repository hygiene checks passed."
