CCT_BIN ?=
CCT_RESOLVER ?= ./scripts/find_cct.sh
PROJECT_NAME := $(shell awk -F'"' '/^[[:space:]]*name[[:space:]]*=[[:space:]]*"/{print $$2; exit}' cct.toml)
PROJECT_VERSION := $(shell awk -F'"' '/^[[:space:]]*version[[:space:]]*=[[:space:]]*"/{print $$2; exit}' cct.toml)
MIN_CCT_VERSION := $(shell awk -F'"' '/^[[:space:]]*cct_min_version[[:space:]]*=[[:space:]]*"/{print $$2; exit}' cct.toml)
CAPABILITY_FLOOR := $(shell awk -F'"' '/^[[:space:]]*cct_capability_floor[[:space:]]*=[[:space:]]*"/{print $$2; exit}' cct.toml)
ROOT_OUT := dist/$(PROJECT_NAME)
EXAMPLE_DIR := examples/salve_civitas
EXAMPLE_NAME := $(shell awk -F'"' '/^[[:space:]]*name[[:space:]]*=[[:space:]]*"/{print $$2; exit}' $(EXAMPLE_DIR)/cct.toml)
EXAMPLE_OUT := dist/$(EXAMPLE_NAME)
EXAMPLE_OUT_FULL := $(EXAMPLE_DIR)/dist/$(EXAMPLE_NAME)
TEMPLATES_DIR ?= templates
TEMPLATES_OUT ?= lib/$(PROJECT_NAME)/templates_gen
TEMPLATE_COMPILER_SRC := bin/cct-template-compile.cct
TEMPLATE_COMPILER_BIN := bin/cct-template-compile
TEMPLATES_SRC := $(shell [ -d "$(TEMPLATES_DIR)" ] && find "$(TEMPLATES_DIR)" -name "*.html" | sort || true)
TEMPLATES_GEN := $(patsubst $(TEMPLATES_DIR)/%.html,$(TEMPLATES_OUT)/%.cct,$(TEMPLATES_SRC))
PHASES ?=

.PHONY: help check-cct template-compile build test examples run-example clean

help:
	@printf '%s\n' \
		'Civitas $(PROJECT_VERSION)' \
		'' \
		'Targets oficiais:' \
		'  make build       Compila o baseline do projeto' \
		'  make template-compile Compila templates HTML do projeto para CCT' \
		'  make test        Executa a suite de integracao do Civitas' \
		'  make examples    Compila o exemplo canônico Salve, Civitas' \
		'  make run-example Compila e executa o exemplo canônico' \
		'  make clean       Remove artefatos gerados' \
		'' \
		'Variaveis uteis:' \
		'  CCT_BIN=<path-ou-nome-do-binario>' \
		'  PHASES=0A|0B|0C|0D|0E|all'

check-cct:
	@RESOLVED_CCT_BIN=`CCT_BIN="$(CCT_BIN)" "$(CCT_RESOLVER)"`; \
	CURRENT_VERSION=`"$$RESOLVED_CCT_BIN" --version | awk '/Clavicula Turing \(CCT\) v/{sub(/^.*v/, ""); print; exit}'`; \
	MIN_VERSION="$(MIN_CCT_VERSION)"; \
	compare_versions() { \
		awk -v current="$$1" -v required="$$2" 'BEGIN { \
			n = split(current, a, "."); \
			m = split(required, b, "."); \
			max = (n > m) ? n : m; \
			for (i = 1; i <= max; i++) { \
				ai = (i in a) ? a[i] + 0 : 0; \
				bi = (i in b) ? b[i] + 0 : 0; \
				if (ai > bi) exit 0; \
				if (ai < bi) exit 1; \
			} \
			exit 0; \
		}'; \
	}; \
	if [ -z "$$CURRENT_VERSION" ]; then \
		echo "Nao foi possivel detectar a versao do CCT em $$RESOLVED_CCT_BIN"; \
		exit 2; \
	fi; \
	if ! compare_versions "$$CURRENT_VERSION" "$$MIN_VERSION"; then \
		echo "Civitas requer CCT >= $$MIN_VERSION, mas o compilador reporta $$CURRENT_VERSION"; \
		exit 2; \
	fi; \
	echo "[cct] binario resolvido: $$RESOLVED_CCT_BIN"; \
	echo "[cct] versao reportada: $$CURRENT_VERSION"; \
	echo "[cct] baseline funcional local: $(CAPABILITY_FLOOR)"

build: check-cct
	@RESOLVED_CCT_BIN=`CCT_BIN="$(CCT_BIN)" "$(CCT_RESOLVER)"`; \
	mkdir -p dist; \
	$(MAKE) --no-print-directory template-compile CCT_BIN="$$RESOLVED_CCT_BIN"; \
	"$$RESOLVED_CCT_BIN" build --project . --out "$(ROOT_OUT)"; \
	echo "[build] baseline compilado em $(ROOT_OUT)"

$(TEMPLATE_COMPILER_BIN): $(TEMPLATE_COMPILER_SRC)
	@RESOLVED_CCT_BIN=`CCT_BIN="$(CCT_BIN)" "$(CCT_RESOLVER)"`; \
	"$$RESOLVED_CCT_BIN" "$(TEMPLATE_COMPILER_SRC)"

$(TEMPLATES_OUT)/%.cct: $(TEMPLATES_DIR)/%.html $(TEMPLATE_COMPILER_BIN)
	@mkdir -p "$(dir $@)"
	@"$(TEMPLATE_COMPILER_BIN)" --template "$<" --output "$@" --root "$(TEMPLATES_DIR)"

template-compile: check-cct $(TEMPLATE_COMPILER_BIN) $(TEMPLATES_GEN)
	@if [ -z "$(TEMPLATES_SRC)" ]; then \
		echo "[template-compile] nenhum template em $(TEMPLATES_DIR)"; \
	else \
		echo "[template-compile] $(words $(TEMPLATES_SRC)) template(s) compilado(s) em $(TEMPLATES_OUT)"; \
	fi

examples: check-cct
	@RESOLVED_CCT_BIN=`CCT_BIN="$(CCT_BIN)" "$(CCT_RESOLVER)"`; \
	mkdir -p "$(EXAMPLE_DIR)/dist"; \
	"$$RESOLVED_CCT_BIN" "$(EXAMPLE_DIR)/main.cct"; \
	cp "$(EXAMPLE_DIR)/main" "$(EXAMPLE_OUT_FULL)"; \
	echo "[examples] exemplo canônico compilado em $(EXAMPLE_OUT_FULL)"

run-example: examples
	@"$(EXAMPLE_OUT_FULL)"

test: check-cct
	@CCT_BIN="$(CCT_BIN)" CCT_RESOLVER="$(CCT_RESOLVER)" bash tests/run_tests.sh $(PHASES)

clean:
	@echo "[clean] removendo artefatos gerados"
	@RESOLVED_CCT_BIN=`CCT_BIN="$(CCT_BIN)" "$(CCT_RESOLVER)" 2>/dev/null || true`; \
	if [ -n "$$RESOLVED_CCT_BIN" ]; then \
		"$$RESOLVED_CCT_BIN" clean --project . --all >/dev/null 2>&1 || true; \
		"$$RESOLVED_CCT_BIN" clean --project "$(EXAMPLE_DIR)" --all >/dev/null 2>&1 || true; \
	fi
	@rm -rf dist "$(EXAMPLE_DIR)/dist" "$(EXAMPLE_DIR)/examples" .cct "$(EXAMPLE_DIR)/.cct" tests/tmp tests/.runner
	@rm -rf examples/mural/var examples/mural/tests/tmp examples/mural_expandido/var examples/rede_social/data examples/rede_social/.civitas
	@rm -rf "$(TEMPLATES_OUT)"
	@rm -f .civitas-pid src/main
	@rm -f "$(EXAMPLE_DIR)/main" "$(EXAMPLE_DIR)/main.cgen.c" "$(EXAMPLE_DIR)/main.sigil" "$(EXAMPLE_DIR)/main.svg" "$(EXAMPLE_DIR)/main.system.sigil" "$(EXAMPLE_DIR)/main.system.svg"
	@rm -f examples/mural/main examples/mural_expandido/main examples/rede_social/project/main
	@rm -f "$(TEMPLATE_COMPILER_BIN)" "$(TEMPLATE_COMPILER_BIN).cgen.c" "$(TEMPLATE_COMPILER_BIN).sigil" "$(TEMPLATE_COMPILER_BIN).svg" "$(TEMPLATE_COMPILER_BIN).system.sigil" "$(TEMPLATE_COMPILER_BIN).system.svg"
	@mkdir -p tests/tmp tests/.runner
