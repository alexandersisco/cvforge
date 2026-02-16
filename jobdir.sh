#!/usr/bin/env bash

project_dir=$(dirname $(realpath $0))

# load config
. "$HOME/.config/cvforge/app.conf"

# validate
: "${JOBS_DIR:?missing JOBS_DIR}"

jobs_path="$(realpath $JOBS_DIR)"

target_dir=""

get_target_dir() {
  local dir=$(find "$jobs_path" -type d | sed "s|${jobs_path}/||" | fzf)

  if [[ ! -z "$dir" ]]; then
    target_dir="$jobs_path/$dir"
    echo "$target_dir"
    return
  fi

  echo ""
}

get_target_dir
