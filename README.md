# cp-sdk-generator

Central OpenAPI SDK generator repository for Platon Control Panel client libraries.

This repository fetches the canonical OpenAPI specification from `https://setup.platon.sk/api/openapi.json`, validates it, and regenerates language-specific SDKs with `openapi-generator-cli`.

## What This Repo Owns

- `openapi/`: fetched OpenAPI snapshot used as generator input.
- `config/`: per-language OpenAPI Generator config files.
- `scripts/`: cross-platform automation for fetch, validate, generate, clean, and future publish workflows.
- `sdk/php`, `sdk/typescript`, `sdk/kotlin`, `sdk/swift`: generated SDK repositories mounted as Git submodules.
- `templates/`: optional mustache overrides for future generator customization.

The `sdk/*` directories are Git submodules. Treat them as generated outputs owned by this orchestrator repo, not as hand-maintained source trees.

## Generator Stack

All SDK generation in this repository uses `openapi-generator-cli`.

- PHP: `php`
- TypeScript: `typescript-axios`
- Kotlin: `kotlin`
- Swift: `swift6`

The Swift scaffold intentionally uses the `swift6` generator because the official `swift5` generator is deprecated in current OpenAPI Generator documentation.

The wrapper version is pinned in `openapitools.json` for reproducible generation.

## Requirements

- Java 17+
- Node.js with `openapi-generator-cli` available on `PATH`
- `curl`
- Git with submodules initialized

Bootstrap the workspace:

```bash
git submodule update --init --recursive
```

## Common Workflows

Refresh the local OpenAPI snapshot:

```bash
./scripts/fetch-openapi.sh
scripts\fetch-openapi.bat
```

Validate the fetched spec:

```bash
./scripts/validate-openapi.sh
scripts\validate-openapi.bat
```

Generate all SDKs:

```bash
./scripts/generate-all.sh
./scripts/generate-all.sh --clean
scripts\generate-all.bat
scripts\generate-all.bat --clean
```

Generate a single SDK:

```bash
./scripts/generate-php.sh
./scripts/generate-typescript.sh
./scripts/generate-kotlin.sh
./scripts/generate-swift.sh
```

Override the release version during generation:

```bash
SDK_VERSION=1.2.3 ./scripts/generate-typescript.sh
set SDK_VERSION=1.2.3 && scripts\generate-typescript.bat
```

## Architecture

The intended workflow is:

1. Fetch `openapi/openapi.json` from the live API.
2. Validate the spec with `openapi-generator-cli validate`.
3. Generate each SDK into its existing submodule directory.
4. Run language-specific tests inside the affected `sdk/<language>` repository.
5. Commit orchestrator changes here and generated SDK changes inside the relevant submodule repo.

Optional extension points already scaffolded:

- `templates/<language>/`: custom OpenAPI Generator mustache templates.
- `scripts/postprocess/<language>.sh|.bat`: post-generation normalization hooks.

## Generated Code Policy

Do not edit generated SDK source files in `sdk/*` by hand.

If an SDK needs to change, update one of these inputs instead:

- the OpenAPI spec in `openapi/openapi.json`,
- the generator config in `config/*.yaml`,
- future custom templates in `templates/`,
- post-processing hooks in `scripts/postprocess/`.

That keeps regeneration deterministic and prevents drift between SDKs.
