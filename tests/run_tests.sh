#!/bin/bash

set -u

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR" || exit 1

CCT_BIN_OVERRIDE="${CCT_BIN:-}"
CCT_RESOLVER="${CCT_RESOLVER:-./scripts/find_cct.sh}"
RUNNER_DIR="$(mktemp -d "${TMPDIR:-/tmp}/civitas-runner.XXXXXX")"
trap 'rm -rf "$RUNNER_DIR"' EXIT
mkdir -p tests/tmp
CCT_BIN="$(CCT_BIN="$CCT_BIN_OVERRIDE" "$CCT_RESOLVER")"

extract_fail_count() {
    local log="$1"
    awk -F'fail=' '/\[test\] summary:/{split($2, a, /[^0-9]/); print a[1]; exit}' "$log"
}

assert_phase_log() {
    local phase="$1"
    local log="$2"

    if [ ! -f "$log" ]; then
        echo "[phase $phase] falhou: log ausente em $log"
        exit 1
    fi

    cat "$log"

    if ! grep -q '\[test\] summary:' "$log"; then
        echo "[phase $phase] falhou: resumo de testes ausente em $log"
        exit 1
    fi
}

run_phase() {
    local phase="$1"
    local pattern="$2"
    local log="${RUNNER_DIR}/run_${phase}.log"
    local rc=0
    local fail_count=0

    echo "[phase $phase] inicio"
    mkdir -p tests/tmp
    "$CCT_BIN" test "$pattern" --project . >"$log" 2>&1 || rc=$?
    assert_phase_log "$phase" "$log"
    fail_count="$(extract_fail_count "$log")"
    if [ -z "$fail_count" ]; then
        echo "[phase $phase] falhou: nao foi possivel extrair fail_count"
        exit 1
    fi
    if [ "$rc" -ne 0 ] || [ "$fail_count" -ne 0 ]; then
        echo "[phase $phase] falhou"
        exit 1
    fi
    echo "[phase $phase] ok"
}

run_phase_serial() {
    local phase="$1"
    shift
    local rc=0
    local fail_count=0
    local pattern=""
    local log=""

    echo "[phase $phase] inicio"
    mkdir -p tests/tmp

    for pattern in "$@"; do
        log="${RUNNER_DIR}/run_${phase}_$(echo "$pattern" | tr -c '[:alnum:]' '_').log"
        rc=0
        fail_count=0
        "$CCT_BIN" test "$pattern" --project . >"$log" 2>&1 || rc=$?
        assert_phase_log "$phase" "$log"
        fail_count="$(extract_fail_count "$log")"
        if [ -z "$fail_count" ]; then
            echo "[phase $phase] falhou: nao foi possivel extrair fail_count"
            exit 1
        fi
        if [ "$rc" -ne 0 ] || [ "$fail_count" -ne 0 ]; then
            echo "[phase $phase] falhou"
            exit 1
        fi
    done

    echo "[phase $phase] ok"
}

phase_selected() {
    local wanted="$1"
    shift || true

    if [ "$#" -eq 0 ]; then
        return 0
    fi

    for arg in "$@"; do
        if [ "$arg" = "all" ] || [ "$arg" = "$wanted" ]; then
            return 0
        fi
    done

    return 1
}

SELECTED=("$@")
if [ -n "${CIVITAS_TEST_PHASES:-}" ]; then
    IFS=',' read -r -a SELECTED <<<"$CIVITAS_TEST_PHASES"
fi
if [ "${#SELECTED[@]}" -eq 0 ]; then
    SELECTED=(all)
fi

echo "Civitas test suite"
echo "[history] FASE 0 permanece como baseline operacional do bootstrap."
echo "[history] FASE 1 amplia o baseline com servidor HTTP síncrono, URL, cookies, MIME, hardening e proxy awareness."
echo "[history] FASE 2 introduz o web core com Request, Response, middleware, router, visibilidade e paginacao."
echo "[history] FASE 3 introduz hooks locais, barramento semantico e outbox duravel pos-commit."
echo "[history] FASE 4 introduz settings canonicos, Application, servicos externos tipados e segredos com rotacao."
echo "[history] FASE 5 introduz seguranca base com headers, CSP, host validation, rate limiting, path guard, CSRF com segredo rotativo e anti-abuso complementar."
echo "[history] FASE 6 introduz templates compilados, compilador de templates, builder HTML seguro e helpers editoriais/publicos."
echo "[history] FASE 7 introduz ciclo completo de formularios com parse, validacao declarativa, sanitizacao rica de conteudo e render HTML extensivel com contrato explicito de memoria."
echo "[history] FASE 8 introduz sessao server-side, flash messages de um request, backend Redis, contexto autenticado por request e o descriptor canonico de arquivo para FkBlob."
echo "[history] FASE 9 introduz upload streaming, static files com cache busting, storage de midia, pipeline de imagem e video e delivery autenticado com range requests."
echo "[history] FASE 10 introduz schema declarativo, query builder explicito, migracoes versionadas e a primeira camada de conteudo estruturado sobre SQLite."
echo "[history] FASE 11 introduz DbHandle multi-backend, pool de conexoes, transacoes aninhadas, busca full-text PostgreSQL e advisory locks para concorrencia segura."
echo "[history] FASE 12 introduz cache multicamada com backend unificado, cache de response HTTP, cache de query e coordenacao de invalidacao com anti-stampede."
echo "[history] FASE 13 introduz fixtures declarativas, factory para testes, banco isolado por savepoint, data IO administrativo e toolkit de migracao Django → Civitas."
echo "[history] FASE 14 introduz i18n e l10n baseline com registry de catalogos, locale por request, catalogo JSON nativo e formatacao localizada avancada."
echo "[history] FASE 15 introduz autenticacao completa com usuarios, tokens HMAC, permissoes, sessao server-side, middleware unificado, rate limit de login e helpers de teste."
echo "[history] FASE 16 introduz recuperacao de conta e verificacao de email com tokens TTL, historico de senhas, mailer canonico, templates transacionais e helpers de teste para captura de emails."
echo "[history] FASE 17 introduz execucao em background com fila persistente, scheduler, retencao segura, pipeline pesado de midia e automacoes editoriais audiveis."
echo "[history] FASE 18 introduz painel admin operacional com registry de modelos, CRUD/listagem/bulk, inlines, moderacao auditavel e dashboards de operacao."
echo "[history] FASE 19 introduz API REST nativa, OpenAPI 3.1 derivado, publicacao publica com SEO tecnico, embeds e exportacoes autenticadas."
echo "[history] FASE 20 introduz observabilidade de request com instrumentacao viva, collector por request, trace store SQLite e spans explicitos para subsistemas criticos."
echo "[history] FASE 21 introduz visualizacao viva dos traces com renderer SVG animado, painel HTML de diagnostico e exportacao ZIP offline por endpoint."
echo "[history] FASE 22 introduz dev server com watch/rebuild, toolbar de debug HTML e livereload, sempre apontando para os sigilos animados completos do CCT."
echo "[history] FASE 23 introduz scaffolding e CLI nativa com new, generate, management commands, civitas.toml compartilhado e doctor para diagnostico de projeto."
echo "[history] FASE 24 introduz harnesses de integracao sem socket para HTTP, email, tasks e SEO, reduzindo latencia de suite e eliminando dependencias externas de teste."
echo "[history] FASE 25 introduz protocolos realtime com SSE e WebSocket, relay SQLite cross-process, presence SSE, estado persistido de salas WS e scaffold canonico de projeto com separacao clara entre framework/runtime e codigo do usuario."
echo "[history] FASE 26 introduz benchmark in-process, profiler de CPU/queries, memory profiler por request e perf report HTML com hotspots exportados para sigilo animado real do CCT."
echo "[history] FASE 27 introduz topologia operacional de storage, backup verificavel de SQLite e midia, restore seguro e rollback local de binario para ambientes file-backed."
echo "[history] FASE 28 fecha a linha 1.0 com auditoria final, fuzzing HTTP, carga in-process, watch de memoria, revisao local de dependencias/CVEs e bundle de documentacao/release."
echo "[history] EXEMPLO Mural consolida o baseline 0-9 com HTML real, formulario, validacao, SQLite, admin-lite e static files em um app instalavel."
echo "[history] EXEMPLO rede_social usa o scaffold novo por apps para montar uma pequena rede social do zero com superficies operacionais e observabilidade do Civitas."

if phase_selected "0A" "${SELECTED[@]}"; then
    run_phase "0A" "fase0_0a_"
fi

if phase_selected "0B" "${SELECTED[@]}"; then
    run_phase "0B" "fase0_0b_"
    echo "[regression] 0A continua verde."
fi

if phase_selected "0C" "${SELECTED[@]}"; then
    run_phase "0C" "fase0_0c_"
    echo "[regression] 0A-0B continuam verdes."
fi

if phase_selected "0D" "${SELECTED[@]}"; then
    run_phase "0D" "fase0_0d_"
    echo "[regression] 0A-0C continuam verdes."
fi

if phase_selected "0E" "${SELECTED[@]}"; then
    run_phase "0E" "fase0_0e_"
    echo "[regression] 0A-0D continuam verdes."
fi

if phase_selected "1A" "${SELECTED[@]}"; then
    run_phase "1A" "fase1_1a_"
    echo "[regression] FASE 0 continua verde apos o servidor HTTP base."
fi

if phase_selected "1B" "${SELECTED[@]}"; then
    run_phase "1B" "fase1_1b_"
    echo "[regression] 0A-0E e 1A continuam verdes."
fi

if phase_selected "1C" "${SELECTED[@]}"; then
    run_phase "1C" "fase1_1c_"
    echo "[regression] 0A-0E e 1A-1B continuam verdes."
fi

if phase_selected "1D" "${SELECTED[@]}"; then
    run_phase "1D" "fase1_1d_"
    echo "[regression] 0A-0E e 1A-1C continuam verdes."
fi

if phase_selected "1E" "${SELECTED[@]}"; then
    run_phase "1E" "fase1_1e_"
    echo "[regression] 0A-0E e 1A-1D continuam verdes."
fi

if phase_selected "1F" "${SELECTED[@]}"; then
    run_phase "1F" "fase1_1f_"
    echo "[regression] 0A-0E e 1A-1E continuam verdes."
fi

if phase_selected "2A" "${SELECTED[@]}"; then
    run_phase "2A" "fase2_2a_"
    echo "[regression] 0A-0E e 1A-1F continuam verdes com Request canonica."
fi

if phase_selected "2B" "${SELECTED[@]}"; then
    run_phase "2B" "fase2_2b_"
    echo "[regression] 0A-0E, 1A-1F e 2A continuam verdes."
fi

if phase_selected "2C" "${SELECTED[@]}"; then
    run_phase "2C" "fase2_2c_"
    echo "[regression] 0A-0E, 1A-1F e 2A-2B continuam verdes."
fi

if phase_selected "2D" "${SELECTED[@]}"; then
    run_phase "2D" "fase2_2d_"
    echo "[regression] 0A-0E, 1A-1F e 2A-2C continuam verdes."
fi

if phase_selected "2E" "${SELECTED[@]}"; then
    run_phase "2E" "fase2_2e_"
    echo "[regression] 0A-0E, 1A-1F e 2A-2D continuam verdes."
fi

if phase_selected "2F" "${SELECTED[@]}"; then
    run_phase "2F" "fase2_2f_"
    echo "[regression] 0A-0E, 1A-1F e 2A-2E continuam verdes."
fi

if phase_selected "3A" "${SELECTED[@]}"; then
    run_phase "3A" "fase3_3a_"
    echo "[regression] 0A-0E, 1A-1F e 2A-2F continuam verdes."
fi

if phase_selected "3B" "${SELECTED[@]}"; then
    run_phase "3B" "fase3_3b_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F e 3A continuam verdes."
fi

if phase_selected "3C" "${SELECTED[@]}"; then
    run_phase "3C" "fase3_3c_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F e 3A-3B continuam verdes."
fi

if phase_selected "4A" "${SELECTED[@]}"; then
    run_phase "4A" "fase4_4a_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F e 3A-3C continuam verdes com settings canonicos."
fi

if phase_selected "4B" "${SELECTED[@]}"; then
    run_phase "4B" "fase4_4b_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C e 4A continuam verdes."
fi

if phase_selected "4C" "${SELECTED[@]}"; then
    run_phase "4C" "fase4_4c_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C e 4A-4B continuam verdes."
fi

if phase_selected "4D" "${SELECTED[@]}"; then
    run_phase "4D" "fase4_4d_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C e 4A-4C continuam verdes."
fi

if phase_selected "5A" "${SELECTED[@]}"; then
    run_phase "5A" "fase5_5a_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C e 4A-4D continuam verdes."
fi

if phase_selected "5B" "${SELECTED[@]}"; then
    run_phase "5B" "fase5_5b_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D e 5A continuam verdes."
fi

if phase_selected "5C" "${SELECTED[@]}"; then
    run_phase "5C" "fase5_5c_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D e 5A-5B continuam verdes."
fi

if phase_selected "6A" "${SELECTED[@]}"; then
    run_phase "6A" "fase6_6a_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D e 5A-5C continuam verdes."
fi

if phase_selected "6B" "${SELECTED[@]}"; then
    run_phase "6B" "fase6_6b_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C e 6A continuam verdes."
fi

if phase_selected "6C" "${SELECTED[@]}"; then
    run_phase "6C" "fase6_6c_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C e 6A-6B continuam verdes."
fi

if phase_selected "6D" "${SELECTED[@]}"; then
    run_phase "6D" "fase6_6d_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C e 6A-6C continuam verdes."
fi

if phase_selected "7A" "${SELECTED[@]}"; then
    run_phase "7A" "fase7_7a_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C e 6A-6D continuam verdes."
fi

if phase_selected "7B" "${SELECTED[@]}"; then
    run_phase "7B" "fase7_7b_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D e 7A continuam verdes."
fi

if phase_selected "7C" "${SELECTED[@]}"; then
    run_phase "7C" "fase7_7c_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D e 7A-7B continuam verdes."
fi

if phase_selected "7D" "${SELECTED[@]}"; then
    run_phase "7D" "fase7_7d_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D e 7A-7C continuam verdes."
fi

if phase_selected "7E" "${SELECTED[@]}"; then
    run_phase "7E" "fase7_7e_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D e 7A-7D continuam verdes."
fi

if phase_selected "8A" "${SELECTED[@]}"; then
    run_phase "8A" "fase8_8a_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D e 7A-7E continuam verdes."
fi

if phase_selected "8B" "${SELECTED[@]}"; then
    run_phase "8B" "fase8_8b_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E e 8A continuam verdes."
fi

if phase_selected "8C" "${SELECTED[@]}"; then
    run_phase "8C" "fase8_8c_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E e 8A-8B continuam verdes."
fi

if phase_selected "8D" "${SELECTED[@]}"; then
    run_phase "8D" "fase8_8d_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E e 8A-8C continuam verdes."
fi

if phase_selected "9A" "${SELECTED[@]}"; then
    run_phase "9A" "fase9_9a_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E e 8A-8D continuam verdes."
fi

if phase_selected "9B" "${SELECTED[@]}"; then
    run_phase "9B" "fase9_9b_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D e 9A continuam verdes."
fi

if phase_selected "9C" "${SELECTED[@]}"; then
    run_phase "9C" "fase9_9c_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D e 9A-9B continuam verdes."
fi

if phase_selected "9D" "${SELECTED[@]}"; then
    run_phase "9D" "fase9_9d_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D e 9A-9C continuam verdes."
fi

if phase_selected "9E" "${SELECTED[@]}"; then
    run_phase "9E" "fase9_9e_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D e 9A-9D continuam verdes."
fi

if phase_selected "9F" "${SELECTED[@]}"; then
    run_phase "9F" "fase9_9f_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D e 9A-9E continuam verdes."
fi

if phase_selected "10A" "${SELECTED[@]}"; then
    run_phase "10A" "fase10_10a_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D e 9A-9F continuam verdes."
fi

if phase_selected "10B" "${SELECTED[@]}"; then
    run_phase "10B" "fase10_10b_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F e 10A continuam verdes."
fi

if phase_selected "10C" "${SELECTED[@]}"; then
    run_phase "10C" "fase10_10c_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F e 10A-10B continuam verdes."
fi

if phase_selected "10D" "${SELECTED[@]}"; then
    run_phase "10D" "fase10_10d_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F e 10A-10C continuam verdes."
fi

if phase_selected "10E" "${SELECTED[@]}"; then
    run_phase "10E" "fase10_10e_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F e 10A-10D continuam verdes."
fi

if phase_selected "10F" "${SELECTED[@]}"; then
    run_phase "10F" "fase10_10f_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F e 10A-10E continuam verdes."
fi

if phase_selected "10G" "${SELECTED[@]}"; then
    run_phase "10G" "fase10_10g_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F e 10A-10F continuam verdes."
fi

if phase_selected "11A" "${SELECTED[@]}"; then
    run_phase "11A" "fase11_11a_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F e 10A-10G continuam verdes."
fi

if phase_selected "11B" "${SELECTED[@]}"; then
    run_phase "11B" "fase11_11b_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G e 11A continuam verdes."
fi

if phase_selected "11C" "${SELECTED[@]}"; then
    run_phase "11C" "fase11_11c_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G e 11A-11B continuam verdes."
fi

if phase_selected "11D" "${SELECTED[@]}"; then
    run_phase "11D" "fase11_11d_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G e 11A-11C continuam verdes."
fi

if phase_selected "11E" "${SELECTED[@]}"; then
    run_phase "11E" "fase11_11e_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G e 11A-11D continuam verdes."
fi

if phase_selected "12A" "${SELECTED[@]}"; then
    run_phase "12A" "fase12_12a_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G e 11A-11E continuam verdes."
fi

if phase_selected "12B" "${SELECTED[@]}"; then
    run_phase "12B" "fase12_12b_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E e 12A continuam verdes."
fi

if phase_selected "12C" "${SELECTED[@]}"; then
    run_phase "12C" "fase12_12c_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E e 12A-12B continuam verdes."
fi

if phase_selected "12D" "${SELECTED[@]}"; then
    run_phase "12D" "fase12_12d_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E e 12A-12C continuam verdes."
fi

if phase_selected "13A" "${SELECTED[@]}"; then
    run_phase "13A" "fase13_13a_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E e 12A-12D continuam verdes."
fi

if phase_selected "13B" "${SELECTED[@]}"; then
    run_phase "13B" "fase13_13b_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D e 13A continuam verdes."
fi

if phase_selected "13C" "${SELECTED[@]}"; then
    run_phase "13C" "fase13_13c_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D e 13A-13B continuam verdes."
fi

if phase_selected "13D" "${SELECTED[@]}"; then
    run_phase "13D" "fase13_13d_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D e 13A-13C continuam verdes."
fi

if phase_selected "13E" "${SELECTED[@]}"; then
    run_phase "13E" "fase13_13e_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D e 13A-13D continuam verdes."
fi

if phase_selected "14A" "${SELECTED[@]}"; then
    run_phase "14A" "fase14_14a_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D e 13A-13E continuam verdes."
fi

if phase_selected "14B" "${SELECTED[@]}"; then
    run_phase "14B" "fase14_14b_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E e 14A continuam verdes."
fi

if phase_selected "14C" "${SELECTED[@]}"; then
    run_phase "14C" "fase14_14c_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E e 14A-14B continuam verdes."
fi

if phase_selected "14D" "${SELECTED[@]}"; then
    run_phase "14D" "fase14_14d_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E e 14A-14C continuam verdes."
fi

if phase_selected "14E" "${SELECTED[@]}"; then
    run_phase "14E" "fase14_14e_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E e 14A-14D continuam verdes."
fi

if phase_selected "15A" "${SELECTED[@]}"; then
    run_phase "15A" "fase15_15a_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E e 14A-14E continuam verdes."
fi

if phase_selected "15B" "${SELECTED[@]}"; then
    run_phase "15B" "fase15_15b_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E, 14A-14E e 15A continuam verdes."
fi

if phase_selected "15C" "${SELECTED[@]}"; then
    run_phase "15C" "fase15_15c_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E, 14A-14E e 15A-15B continuam verdes."
fi

if phase_selected "15D" "${SELECTED[@]}"; then
    run_phase "15D" "fase15_15d_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E, 14A-14E e 15A-15C continuam verdes."
fi

if phase_selected "15E" "${SELECTED[@]}"; then
    run_phase "15E" "fase15_15e_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E, 14A-14E e 15A-15D continuam verdes."
fi

if phase_selected "15F" "${SELECTED[@]}"; then
    run_phase "15F" "fase15_15f_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E, 14A-14E e 15A-15E continuam verdes."
fi

if phase_selected "15G" "${SELECTED[@]}"; then
    run_phase "15G" "fase15_15g_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E, 14A-14E e 15A-15F continuam verdes."
fi

if phase_selected "16A" "${SELECTED[@]}"; then
    run_phase "16A" "fase16_16a_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E, 14A-14E e 15A-15G continuam verdes."
fi

if phase_selected "16B" "${SELECTED[@]}"; then
    run_phase "16B" "fase16_16b_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E, 14A-14E, 15A-15G e 16A continuam verdes."
fi

if phase_selected "16C" "${SELECTED[@]}"; then
    run_phase "16C" "fase16_16c_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E, 14A-14E, 15A-15G e 16A-16B continuam verdes."
fi

if phase_selected "16D" "${SELECTED[@]}"; then
    run_phase "16D" "fase16_16d_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E, 14A-14E, 15A-15G e 16A-16C continuam verdes."
fi

if phase_selected "17A" "${SELECTED[@]}"; then
    run_phase "17A" "fase17_17a_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E, 14A-14E, 15A-15G e 16A-16D continuam verdes."
fi

if phase_selected "17B" "${SELECTED[@]}"; then
    run_phase "17B" "fase17_17b_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E, 14A-14E, 15A-15G, 16A-16D e 17A continuam verdes."
fi

if phase_selected "17C" "${SELECTED[@]}"; then
    run_phase "17C" "fase17_17c_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E, 14A-14E, 15A-15G, 16A-16D e 17A-17B continuam verdes."
fi

if phase_selected "17D" "${SELECTED[@]}"; then
    run_phase "17D" "fase17_17d_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E, 14A-14E, 15A-15G, 16A-16D e 17A-17C continuam verdes."
fi

if phase_selected "17E" "${SELECTED[@]}"; then
    run_phase "17E" "fase17_17e_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E, 14A-14E, 15A-15G, 16A-16D e 17A-17D continuam verdes."
fi

if phase_selected "18A" "${SELECTED[@]}"; then
    run_phase "18A" "fase18_18a_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E, 14A-14E, 15A-15G, 16A-16D e 17A-17E continuam verdes."
fi

if phase_selected "18B" "${SELECTED[@]}"; then
    run_phase "18B" "fase18_18b_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E, 14A-14E, 15A-15G, 16A-16D, 17A-17E e 18A continuam verdes."
fi

if phase_selected "18C" "${SELECTED[@]}"; then
    run_phase "18C" "fase18_18c_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E, 14A-14E, 15A-15G, 16A-16D, 17A-17E e 18A-18B continuam verdes."
fi

if phase_selected "18D" "${SELECTED[@]}"; then
    run_phase "18D" "fase18_18d_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E, 14A-14E, 15A-15G, 16A-16D, 17A-17E e 18A-18C continuam verdes."
fi

if phase_selected "18E" "${SELECTED[@]}"; then
    run_phase "18E" "fase18_18e_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E, 14A-14E, 15A-15G, 16A-16D, 17A-17E e 18A-18D continuam verdes."
fi

if phase_selected "19A" "${SELECTED[@]}"; then
    run_phase "19A" "fase19_19a_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E, 14A-14E, 15A-15G, 16A-16D, 17A-17E e 18A-18E continuam verdes."
fi

if phase_selected "19B" "${SELECTED[@]}"; then
    run_phase "19B" "fase19_19b_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E, 14A-14E, 15A-15G, 16A-16D, 17A-17E, 18A-18E e 19A continuam verdes."
fi

if phase_selected "19C" "${SELECTED[@]}"; then
    run_phase "19C" "fase19_19c_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E, 14A-14E, 15A-15G, 16A-16D, 17A-17E, 18A-18E e 19A-19B continuam verdes."
fi

if phase_selected "19D" "${SELECTED[@]}"; then
    run_phase "19D" "fase19_19d_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E, 14A-14E, 15A-15G, 16A-16D, 17A-17E, 18A-18E e 19A-19C continuam verdes."
fi

if phase_selected "19E" "${SELECTED[@]}"; then
    run_phase "19E" "fase19_19e_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E, 14A-14E, 15A-15G, 16A-16D, 17A-17E, 18A-18E e 19A-19D continuam verdes."
fi

if phase_selected "20A" "${SELECTED[@]}"; then
    run_phase "20A" "fase20_20a_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E, 14A-14E, 15A-15G, 16A-16D, 17A-17E, 18A-18E e 19A-19E continuam verdes."
fi

if phase_selected "20B" "${SELECTED[@]}"; then
    run_phase "20B" "fase20_20b_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E, 14A-14E, 15A-15G, 16A-16D, 17A-17E, 18A-18E, 19A-19E e 20A continuam verdes."
fi

if phase_selected "20C" "${SELECTED[@]}"; then
    run_phase "20C" "fase20_20c_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E, 14A-14E, 15A-15G, 16A-16D, 17A-17E, 18A-18E, 19A-19E e 20A-20B continuam verdes."
fi

if phase_selected "20D" "${SELECTED[@]}"; then
    run_phase "20D" "fase20_20d_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E, 14A-14E, 15A-15G, 16A-16D, 17A-17E, 18A-18E, 19A-19E e 20A-20C continuam verdes."
fi

if phase_selected "21A" "${SELECTED[@]}"; then
    run_phase "21A" "fase21_21a_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E, 14A-14E, 15A-15G, 16A-16D, 17A-17E, 18A-18E, 19A-19E e 20A-20D continuam verdes."
fi

if phase_selected "21B" "${SELECTED[@]}"; then
    run_phase "21B" "fase21_21b_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E, 14A-14E, 15A-15G, 16A-16D, 17A-17E, 18A-18E, 19A-19E, 20A-20D e 21A continuam verdes."
fi

if phase_selected "21C" "${SELECTED[@]}"; then
    run_phase "21C" "fase21_21c_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E, 14A-14E, 15A-15G, 16A-16D, 17A-17E, 18A-18E, 19A-19E, 20A-20D e 21A-21B continuam verdes."
fi

if phase_selected "22A" "${SELECTED[@]}"; then
    run_phase "22A" "fase22_22a_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E, 14A-14E, 15A-15G, 16A-16D, 17A-17E, 18A-18E, 19A-19E, 20A-20D e 21A-21C continuam verdes."
fi

if phase_selected "22B" "${SELECTED[@]}"; then
    run_phase "22B" "fase22_22b_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E, 14A-14E, 15A-15G, 16A-16D, 17A-17E, 18A-18E, 19A-19E, 20A-20D, 21A-21C e 22A continuam verdes."
fi

if phase_selected "22C" "${SELECTED[@]}"; then
    run_phase "22C" "fase22_22c_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E, 14A-14E, 15A-15G, 16A-16D, 17A-17E, 18A-18E, 19A-19E, 20A-20D, 21A-21C e 22A-22B continuam verdes."
fi

if phase_selected "23A" "${SELECTED[@]}"; then
    run_phase "23A" "fase23_23a_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E, 14A-14E, 15A-15G, 16A-16D, 17A-17E, 18A-18E, 19A-19E, 20A-20D, 21A-21C e 22A-22C continuam verdes."
fi

if phase_selected "23B" "${SELECTED[@]}"; then
    run_phase "23B" "fase23_23b_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E, 14A-14E, 15A-15G, 16A-16D, 17A-17E, 18A-18E, 19A-19E, 20A-20D, 21A-21C, 22A-22C e 23A continuam verdes."
fi

if phase_selected "23C" "${SELECTED[@]}"; then
    run_phase "23C" "fase23_23c_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E, 14A-14E, 15A-15G, 16A-16D, 17A-17E, 18A-18E, 19A-19E, 20A-20D, 21A-21C, 22A-22C e 23A-23B continuam verdes."
fi

if phase_selected "23D" "${SELECTED[@]}"; then
    run_phase "23D" "fase23_23d_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E, 14A-14E, 15A-15G, 16A-16D, 17A-17E, 18A-18E, 19A-19E, 20A-20D, 21A-21C, 22A-22C e 23A-23C continuam verdes."
fi

if phase_selected "24A" "${SELECTED[@]}"; then
    run_phase "24A" "fase24_24a_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E, 14A-14E, 15A-15G, 16A-16D, 17A-17E, 18A-18E, 19A-19E, 20A-20D, 21A-21C, 22A-22C e 23A-23D continuam verdes."
fi

if phase_selected "24B" "${SELECTED[@]}"; then
    run_phase "24B" "fase24_24b_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E, 14A-14E, 15A-15G, 16A-16D, 17A-17E, 18A-18E, 19A-19E, 20A-20D, 21A-21C, 22A-22C, 23A-23D e 24A continuam verdes."
fi

if phase_selected "24C" "${SELECTED[@]}"; then
    run_phase "24C" "fase24_24c_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E, 14A-14E, 15A-15G, 16A-16D, 17A-17E, 18A-18E, 19A-19E, 20A-20D, 21A-21C, 22A-22C, 23A-23D e 24A-24B continuam verdes."
fi

if phase_selected "24D" "${SELECTED[@]}"; then
    run_phase "24D" "fase24_24d_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E, 14A-14E, 15A-15G, 16A-16D, 17A-17E, 18A-18E, 19A-19E, 20A-20D, 21A-21C, 22A-22C, 23A-23D e 24A-24C continuam verdes."
fi

if phase_selected "25A" "${SELECTED[@]}"; then
    run_phase "25A" "fase25_25a_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E, 14A-14E, 15A-15G, 16A-16D, 17A-17E, 18A-18E, 19A-19E, 20A-20D, 21A-21C, 22A-22C, 23A-23D e 24A-24D continuam verdes."
fi

if phase_selected "25B" "${SELECTED[@]}"; then
    run_phase "25B" "fase25_25b_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E, 14A-14E, 15A-15G, 16A-16D, 17A-17E, 18A-18E, 19A-19E, 20A-20D, 21A-21C, 22A-22C, 23A-23D, 24A-24D e 25A continuam verdes."
fi

if phase_selected "25C" "${SELECTED[@]}"; then
    run_phase "25C" "fase25_25c_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E, 14A-14E, 15A-15G, 16A-16D, 17A-17E, 18A-18E, 19A-19E, 20A-20D, 21A-21C, 22A-22C, 23A-23D, 24A-24D e 25A-25B continuam verdes."
fi

if phase_selected "25D" "${SELECTED[@]}"; then
    run_phase "25D" "fase25_25d_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E, 14A-14E, 15A-15G, 16A-16D, 17A-17E, 18A-18E, 19A-19E, 20A-20D, 21A-21C, 22A-22C, 23A-23D, 24A-24D e 25A-25C continuam verdes."
fi

if phase_selected "25E" "${SELECTED[@]}"; then
    run_phase "25E" "fase25_25e_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E, 14A-14E, 15A-15G, 16A-16D, 17A-17E, 18A-18E, 19A-19E, 20A-20D, 21A-21C, 22A-22C, 23A-23D, 24A-24D e 25A-25D continuam verdes."
fi

if phase_selected "26A" "${SELECTED[@]}"; then
    run_phase "26A" "fase26_26a_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E, 14A-14E, 15A-15G, 16A-16D, 17A-17E, 18A-18E, 19A-19E, 20A-20D, 21A-21C, 22A-22C, 23A-23D, 24A-24D e 25A-25E continuam verdes."
fi

if phase_selected "26B" "${SELECTED[@]}"; then
    run_phase "26B" "fase26_26b_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E, 14A-14E, 15A-15G, 16A-16D, 17A-17E, 18A-18E, 19A-19E, 20A-20D, 21A-21C, 22A-22C, 23A-23D, 24A-24D, 25A-25E e 26A continuam verdes."
fi

if phase_selected "26C" "${SELECTED[@]}"; then
    run_phase "26C" "fase26_26c_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E, 14A-14E, 15A-15G, 16A-16D, 17A-17E, 18A-18E, 19A-19E, 20A-20D, 21A-21C, 22A-22C, 23A-23D, 24A-24D, 25A-25E e 26A-26B continuam verdes."
fi

if phase_selected "26D" "${SELECTED[@]}"; then
    run_phase "26D" "fase26_26d_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E, 14A-14E, 15A-15G, 16A-16D, 17A-17E, 18A-18E, 19A-19E, 20A-20D, 21A-21C, 22A-22C, 23A-23D, 24A-24D, 25A-25E e 26A-26C continuam verdes."
fi

if phase_selected "27A" "${SELECTED[@]}"; then
    run_phase "27A" "fase27_27a_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E, 14A-14E, 15A-15G, 16A-16D, 17A-17E, 18A-18E, 19A-19E, 20A-20D, 21A-21C, 22A-22C, 23A-23D, 24A-24D, 25A-25E e 26A-26D continuam verdes."
fi

if phase_selected "27B" "${SELECTED[@]}"; then
    run_phase "27B" "fase27_27b_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E, 14A-14E, 15A-15G, 16A-16D, 17A-17E, 18A-18E, 19A-19E, 20A-20D, 21A-21C, 22A-22C, 23A-23D, 24A-24D, 25A-25E, 26A-26D e 27A continuam verdes."
fi

if phase_selected "28A" "${SELECTED[@]}"; then
    run_phase "28A" "fase28_28a_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E, 14A-14E, 15A-15G, 16A-16D, 17A-17E, 18A-18E, 19A-19E, 20A-20D, 21A-21C, 22A-22C, 23A-23D, 24A-24D, 25A-25E, 26A-26D e 27A-27B continuam verdes."
fi

if phase_selected "28B" "${SELECTED[@]}"; then
    run_phase "28B" "fase28_28b_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E, 14A-14E, 15A-15G, 16A-16D, 17A-17E, 18A-18E, 19A-19E, 20A-20D, 21A-21C, 22A-22C, 23A-23D, 24A-24D, 25A-25E, 26A-26D, 27A-27B e 28A continuam verdes."
fi

if phase_selected "28C" "${SELECTED[@]}"; then
    run_phase "28C" "fase28_28c_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E, 14A-14E, 15A-15G, 16A-16D, 17A-17E, 18A-18E, 19A-19E, 20A-20D, 21A-21C, 22A-22C, 23A-23D, 24A-24D, 25A-25E, 26A-26D, 27A-27B e 28A-28B continuam verdes."
fi

if phase_selected "28D" "${SELECTED[@]}"; then
    run_phase "28D" "fase28_28d_"
    echo "[regression] 0A-0E, 1A-1F, 2A-2F, 3A-3C, 4A-4D, 5A-5C, 6A-6D, 7A-7E, 8A-8D, 9A-9F, 10A-10G, 11A-11E, 12A-12D, 13A-13E, 14A-14E, 15A-15G, 16A-16D, 17A-17E, 18A-18E, 19A-19E, 20A-20D, 21A-21C, 22A-22C, 23A-23D, 24A-24D, 25A-25E, 26A-26D, 27A-27B e 28A-28C continuam verdes."
fi

if phase_selected "MURAL" "${SELECTED[@]}"; then
    run_phase "MURAL" "mural_example_"
    echo "[regression] fases 0-28 continuam verdes com o exemplo canonico Mural."
fi

if phase_selected "MURAL_EXPANDIDO" "${SELECTED[@]}"; then
    run_phase_serial "MURAL_EXPANDIDO" \
        "mural_expandido_example_basic_auth_headers" \
        "mural_expandido_example_actions_smoke" \
        "mural_expandido_example_server_timeout_smoke"
    echo "[regression] fases 0-28 continuam verdes com o exemplo Mural Expandido."
fi

if phase_selected "REDE_SOCIAL" "${SELECTED[@]}"; then
    run_phase "REDE_SOCIAL" "rede_social_example_"
    echo "[regression] fases 0-28 continuam verdes com o exemplo rede_social."
fi

echo "[summary] fases selecionadas executadas sem regressao."
