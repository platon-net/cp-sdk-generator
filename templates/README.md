# Templates

Place optional OpenAPI Generator mustache overrides here.

Use language-specific directories that match the script keys:

- `templates/php/`
- `templates/typescript/`
- `templates/kotlin/`
- `templates/swift/`

The generation scripts automatically use `templates/<language>/` when that directory exists. You can also override the location with the `TEMPLATE_DIR` environment variable.
