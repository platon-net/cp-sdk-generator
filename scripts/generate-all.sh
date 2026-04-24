#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

clean_first=0
if [[ "${1:-}" == "--clean" ]]; then
  clean_first=1
elif [[ $# -gt 0 ]]; then
  fail "Usage: $(basename "$0") [--clean]"
fi

fetch_openapi
validate_openapi

if [[ "$clean_first" -eq 1 ]]; then
  clean_generated_dir "$REPO_ROOT/sdk/php"
  clean_generated_dir "$REPO_ROOT/sdk/typescript"
  clean_generated_dir "$REPO_ROOT/sdk/kotlin"
  clean_generated_dir "$REPO_ROOT/sdk/swift"
fi

"$SCRIPT_DIR/generate-php.sh"
"$SCRIPT_DIR/generate-typescript.sh"
"$SCRIPT_DIR/generate-kotlin.sh"
"$SCRIPT_DIR/generate-swift.sh"
