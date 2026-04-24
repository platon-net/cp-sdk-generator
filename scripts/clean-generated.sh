#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

target="${1:-all}"

case "$target" in
  all)
    clean_generated_dir "$REPO_ROOT/sdk/php"
    clean_generated_dir "$REPO_ROOT/sdk/typescript"
    clean_generated_dir "$REPO_ROOT/sdk/kotlin"
    clean_generated_dir "$REPO_ROOT/sdk/swift"
    ;;
  php|typescript|kotlin|swift)
    clean_generated_dir "$REPO_ROOT/sdk/$target"
    ;;
  *)
    fail "Usage: $(basename "$0") [php|typescript|kotlin|swift|all]"
    ;;
esac
