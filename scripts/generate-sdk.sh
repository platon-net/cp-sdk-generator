#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

language="${1:-}"
[[ -n "$language" ]] || fail "Usage: $(basename "$0") <php|typescript|kotlin|swift> [--clean]"
shift || true

clean_first=0
for arg in "$@"; do
  case "$arg" in
    --clean)
      clean_first=1
      ;;
    *)
      fail "Unknown argument: $arg"
      ;;
  esac
done

case "$language" in
  php)
    generator="php"
    config="$REPO_ROOT/config/php.yaml"
    output="$REPO_ROOT/sdk/php"
    repo_id="cp-php-sdk"
    ;;
  typescript)
    generator="typescript-axios"
    config="$REPO_ROOT/config/typescript.yaml"
    output="$REPO_ROOT/sdk/typescript"
    repo_id="cp-typescript-sdk"
    ;;
  kotlin)
    generator="kotlin"
    config="$REPO_ROOT/config/kotlin.yaml"
    output="$REPO_ROOT/sdk/kotlin"
    repo_id="cp-kotlin-sdk"
    ;;
  swift)
    generator="swift6"
    config="$REPO_ROOT/config/swift.yaml"
    output="$REPO_ROOT/sdk/swift"
    repo_id="cp-swift-sdk"
    ;;
  *)
    fail "Unsupported SDK language: $language"
    ;;
esac

if [[ "$clean_first" -eq 1 ]]; then
  clean_generated_dir "$output"
fi

generate_sdk "$language" "$generator" "$config" "$output" "$repo_id"
