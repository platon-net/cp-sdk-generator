#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

language="${1:-}"
[[ -n "$language" ]] || fail "Usage: $(basename "$0") <php|typescript|kotlin|swift>"

case "$language" in
  php)
    target="$REPO_ROOT/sdk/php"
    registry_hint="Publish via Composer package workflow for platon-net/cp-php-sdk."
    ;;
  typescript)
    target="$REPO_ROOT/sdk/typescript"
    registry_hint="Publish via npm workflow for cp-typescript-sdk."
    ;;
  kotlin)
    target="$REPO_ROOT/sdk/kotlin"
    registry_hint="Publish via Maven Central or internal Maven workflow for cp-kotlin-sdk."
    ;;
  swift)
    target="$REPO_ROOT/sdk/swift"
    registry_hint="Publish via SwiftPM and optional CocoaPods workflow for cp-swift-sdk."
    ;;
  *)
    fail "Unsupported SDK language: $language"
    ;;
esac

ensure_submodule_dir "$target"
log "Publish workflow is intentionally a scaffold only."
printf '%s\n' "$registry_hint"
printf '%s\n' "Implement language-specific release automation in the SDK submodule or CI before using this command."
exit 1
