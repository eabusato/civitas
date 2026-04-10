# Contributing

## Scope

Civitas is a web framework for CCT. Changes here must preserve the separation between:

- Civitas as a framework/library repository
- CCT as an external compiler/runtime repository

Do not introduce assumptions that the CCT source tree lives beside this repository.

## Setup

1. Install CCT `>= 0.40.0`.
2. Ensure `cct-host` or `cct` is on your `PATH`, or export `CCT_BIN=/path/to/cct-host`.
3. Run `make build` and `make test`.

## Change expectations

- Keep runtime state, local databases, traces, sessions, reports and generated binaries out of git.
- Update docs when behavior changes.
- Prefer integration coverage for framework behavior.
- Keep generated project scaffolds using `CCT_BIN` or `PATH`, not local relative paths.

## Pull requests

- Describe the user-visible or framework-visible change.
- Call out compatibility impact with CCT when relevant.
- Mention commands used for validation.
