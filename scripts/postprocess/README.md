# Post-Processing Hooks

Optional post-generation hooks live here.

Supported naming:

- `scripts/postprocess/php.sh` or `php.bat`
- `scripts/postprocess/typescript.sh` or `typescript.bat`
- `scripts/postprocess/kotlin.sh` or `kotlin.bat`
- `scripts/postprocess/swift.sh` or `swift.bat`

If a matching hook exists, the generate script runs it after `openapi-generator-cli` finishes. Use hooks only for deterministic cleanup that cannot be expressed via the OpenAPI spec, generator config, or templates.
