#!/bin/bash
SRC_DIR=$(pwd)
cd /Users/github/@dataengy/my-dez-2025/common/
pwd
#source "$(dirname "$0")/logger.sh"
#source "$(dirname "$0")/conf.sh"
. logger.sh
. conf.sh

assert_file() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    log_error "${FUNCNAME[0]}" "${BASH_SOURCE[0]}" "$LINENO" "File not found: $file"
    exit 1
  else
    log_success "${FUNCNAME[0]}" "${BASH_SOURCE[0]}" "$LINENO" "File OK: $file"
  fi
}

load_env() {
  local env_file="${1:-.env}"
  assert_file $env_file
  if [[ -f "$env_file" ]]; then
    export $(grep -v '^#' "$env_file" | xargs)
    log_info "${FUNCNAME[0]}" "${BASH_SOURCE[0]}" "$LINENO" "Loaded env from $env_file"
  else
    log_warn "${FUNCNAME[0]}" "${BASH_SOURCE[0]}" "$LINENO" "No .env found"
  fi
}

cd $SRC_DIR