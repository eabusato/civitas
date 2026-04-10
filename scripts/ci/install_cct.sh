#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"

if [[ -n "${CCT_BIN:-}" ]]; then
  if [[ -x "${CCT_BIN}" ]]; then
    printf '%s\n' "${CCT_BIN}"
    exit 0
  fi
  if command -v "${CCT_BIN}" >/dev/null 2>&1; then
    command -v "${CCT_BIN}"
    exit 0
  fi
fi

if command -v cct-host >/dev/null 2>&1; then
  command -v cct-host
  exit 0
fi

if command -v cct >/dev/null 2>&1; then
  command -v cct
  exit 0
fi

TOOLS_DIR="${ROOT_DIR}/.ci-tools"
mkdir -p "${TOOLS_DIR}"

if [[ -n "${CCT_DOWNLOAD_URL:-}" ]]; then
  ARCHIVE_PATH="${TOOLS_DIR}/cct-download"
  curl -fsSL "${CCT_DOWNLOAD_URL}" -o "${ARCHIVE_PATH}"
  EXTRACT_DIR="${TOOLS_DIR}/cct"
  rm -rf "${EXTRACT_DIR}"
  mkdir -p "${EXTRACT_DIR}"
  case "${CCT_DOWNLOAD_URL}" in
    *.tar.gz|*.tgz)
      tar -xzf "${ARCHIVE_PATH}" -C "${EXTRACT_DIR}"
      ;;
    *.zip)
      unzip -q "${ARCHIVE_PATH}" -d "${EXTRACT_DIR}"
      ;;
    *)
      echo "Unsupported CCT_DOWNLOAD_URL archive format: ${CCT_DOWNLOAD_URL}" >&2
      exit 2
      ;;
  esac
  FOUND_BIN="$(find "${EXTRACT_DIR}" -type f \( -name cct-host -o -name cct \) | head -n 1)"
  if [[ -n "${FOUND_BIN}" ]]; then
    chmod +x "${FOUND_BIN}" || true
    printf '%s\n' "${FOUND_BIN}"
    exit 0
  fi
fi

if [[ -n "${CCT_GIT_URL:-}" ]]; then
  SRC_DIR="${TOOLS_DIR}/cct-src"
  rm -rf "${SRC_DIR}"
  git clone --depth 1 "${CCT_GIT_URL}" "${SRC_DIR}"
  if [[ -n "${CCT_GIT_REF:-}" ]]; then
    git -C "${SRC_DIR}" fetch --depth 1 origin "${CCT_GIT_REF}"
    git -C "${SRC_DIR}" checkout "${CCT_GIT_REF}"
  fi
  if [[ -z "${CCT_BUILD_COMMAND:-}" ]]; then
    echo "CCT_BUILD_COMMAND must be set when using CCT_GIT_URL." >&2
    exit 2
  fi
  (
    cd "${SRC_DIR}"
    eval "${CCT_BUILD_COMMAND}"
  )
  if [[ -n "${CCT_BUILT_BIN:-}" ]]; then
    printf '%s\n' "${SRC_DIR}/${CCT_BUILT_BIN}"
    exit 0
  fi
  FOUND_BIN="$(find "${SRC_DIR}" -type f \( -name cct-host -o -name cct \) | head -n 1)"
  if [[ -n "${FOUND_BIN}" ]]; then
    chmod +x "${FOUND_BIN}" || true
    printf '%s\n' "${FOUND_BIN}"
    exit 0
  fi
fi

echo "Unable to install or resolve CCT. Set CCT_BIN, CCT_DOWNLOAD_URL or CCT_GIT_URL+CCT_BUILD_COMMAND." >&2
exit 2
