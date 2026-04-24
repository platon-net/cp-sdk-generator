#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

OPENAPI_SPEC_URL="${OPENAPI_SPEC_URL:-https://setup.platon.sk/api/openapi.json}"
OPENAPI_FILE="${OPENAPI_FILE:-$REPO_ROOT/openapi/openapi.json}"
OPENAPI_GENERATOR_CMD="${OPENAPI_GENERATOR_CMD:-openapi-generator-cli}"
SDK_VERSION="${SDK_VERSION:-1.0.0}"
GIT_HOST="${GIT_HOST:-github.com}"
GIT_USER_ID="${GIT_USER_ID:-platon-net}"

log() {
  printf '==> %s\n' "$*"
}

fail() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || fail "Required command not found on PATH: $1"
}

ensure_spec_dir() {
  mkdir -p "$(dirname "$OPENAPI_FILE")"
}

ensure_submodule_dir() {
  local target="$1"
  [[ -d "$target" ]] || fail "Directory does not exist: $target"
  [[ -e "$target/.git" ]] || fail "Expected git submodule metadata in: $target"
}

fetch_openapi() {
  require_command curl
  ensure_spec_dir

  local tmp_file="${OPENAPI_FILE}.tmp"
  log "Fetching OpenAPI spec from $OPENAPI_SPEC_URL"
  curl --fail --location --silent --show-error "$OPENAPI_SPEC_URL" --output "$tmp_file"
  mv "$tmp_file" "$OPENAPI_FILE"
  log "Saved spec to $OPENAPI_FILE"
}

ensure_openapi() {
  [[ -f "$OPENAPI_FILE" ]] || fetch_openapi
}

validate_openapi() {
  require_command "$OPENAPI_GENERATOR_CMD"
  ensure_openapi
  log "Validating $OPENAPI_FILE"
  "$OPENAPI_GENERATOR_CMD" validate -i "$OPENAPI_FILE" --recommend
}

clean_generated_dir() {
  local target="$1"
  ensure_submodule_dir "$target"
  [[ "$target" == "$REPO_ROOT"/sdk/* ]] || fail "Refusing to clean a directory outside $REPO_ROOT/sdk"

  log "Cleaning generated files in $target"
  find "$target" -mindepth 1 -maxdepth 1 ! -name '.git' -exec rm -rf {} +
}

template_args_for() {
  local language="$1"
  local template_dir="${TEMPLATE_DIR:-$REPO_ROOT/templates/$language}"

  if [[ -d "$template_dir" ]]; then
    printf '%s\0%s\0' "--template-dir" "$template_dir"
  fi
}

version_args_for() {
  case "$1" in
    php|kotlin)
      printf '%s\0%s\0' "--additional-properties" "artifactVersion=$SDK_VERSION"
      ;;
    typescript)
      printf '%s\0%s\0' "--additional-properties" "npmVersion=$SDK_VERSION"
      ;;
    swift)
      printf '%s\0%s\0' "--additional-properties" "podVersion=$SDK_VERSION"
      ;;
    *)
      ;;
  esac
}

run_postprocess_hook() {
  local language="$1"
  local output_dir="$2"
  local hook="$REPO_ROOT/scripts/postprocess/${language}.sh"

  if [[ -x "$hook" ]]; then
    log "Running post-process hook $hook"
    "$hook" "$output_dir"
  fi
}

generate_sdk() {
  local language="$1"
  local generator="$2"
  local config="$3"
  local output="$4"
  local repo_id="$5"
  shift 5

  require_command "$OPENAPI_GENERATOR_CMD"
  ensure_openapi
  ensure_submodule_dir "$output"
  [[ -f "$config" ]] || fail "Generator config does not exist: $config"

  local -a cmd=(
    "$OPENAPI_GENERATOR_CMD"
    generate
    -i "$OPENAPI_FILE"
    -g "$generator"
    -c "$config"
    -o "$output"
    --git-host "$GIT_HOST"
    --git-user-id "$GIT_USER_ID"
    --git-repo-id "$repo_id"
  )

  local -a template_args=()
  while IFS= read -r -d '' item; do
    template_args+=("$item")
  done < <(template_args_for "$language")

  local -a version_args=()
  while IFS= read -r -d '' item; do
    version_args+=("$item")
  done < <(version_args_for "$language")

  cmd+=("${template_args[@]}")
  cmd+=("${version_args[@]}")
  cmd+=("$@")

  log "Generating $language SDK into $output"
  "${cmd[@]}"
  run_postprocess_hook "$language" "$output"
}
