# Repository Guidelines

## Project Structure & Module Organization
This repository is the central SDK generator for the Platon Control Panel API. Keep responsibilities separated:

- `openapi/`: fetched OpenAPI snapshot, primarily `openapi/openapi.json`.
- `config/`: per-language `openapi-generator-cli` configs.
- `scripts/`: fetch, validate, generate, clean, and publish scaffolding for Windows and Unix shells.
- `templates/`: optional future mustache overrides by language.
- `scripts/postprocess/`: optional deterministic post-generation hooks.
- `sdk/php`, `sdk/typescript`, `sdk/kotlin`, `sdk/swift`: generated SDK repositories tracked as Git submodules.

Treat `sdk/*` as outputs. Treat `openapi/`, `config/`, `templates/`, and `scripts/` as the editable inputs.

## Build, Test, and Development Commands
Use the orchestrator scripts from the repo root:

- `git submodule update --init --recursive`: initialize SDK submodules.
- `./scripts/fetch-openapi.sh` or `scripts\fetch-openapi.bat`: refresh `openapi/openapi.json`.
- `./scripts/validate-openapi.sh` or `scripts\validate-openapi.bat`: run `openapi-generator-cli validate`.
- `./scripts/generate-all.sh --clean` or `scripts\generate-all.bat --clean`: clean and regenerate every SDK.
- `./scripts/generate-php.sh`, `generate-typescript.sh`, `generate-kotlin.sh`, `generate-swift.sh`: regenerate one SDK.

Override release metadata with environment variables such as `SDK_VERSION=1.2.3`.

## Coding Style & Naming Conventions
Keep scripts and config readable and deterministic:

- Use lowercase directory names and purpose-based script names such as `generate-kotlin.sh`.
- Keep YAML, JSON, shell, and batch files formatted conservatively and ASCII-first.
- Prefer small changes in generator inputs over direct edits in generated outputs.
- Keep future template overrides in `templates/<language>/` and future cleanup hooks in `scripts/postprocess/<language>.sh|.bat`.

## Testing Guidelines
Validate the level you changed:

- For spec/config/script updates, run fetch, validate, and the affected generate script.
- For full regeneration changes, prefer `generate-all --clean` and review diffs in both this repo and the touched submodule.
- Run language-specific tests inside the affected `sdk/<language>` submodule before publishing.

## Commit & Pull Request Guidelines
The existing history uses short descriptive subjects. Follow that style with imperative messages, for example `add swift6 generator scaffold`.

PRs should include the reason for the change, the validation commands run, and whether submodule pointers changed.

## Agent-Specific Rules
Agents must change SDK behavior only through supported inputs:

- OpenAPI spec updates in `openapi/openapi.json`
- generator config updates in `config/*.yaml`
- template overrides in `templates/`
- deterministic post-processing in `scripts/postprocess/`

Do not manually edit generated SDK source code in `sdk/*`. If a direct SDK edit seems necessary, move the change upstream into the spec, generator config, templates, or post-processing instead.
