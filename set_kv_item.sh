#!/usr/bin/env bash

set_kv_item() {
  local kv_file="./kv_store.txt"
  if [[ ! -f "$kv_file" ]]; then
    touch "$kv_file"
  fi

  local key="$1"
  local val="$2"

  if grep -q "^$key=" "$kv_file"; then
    sed -i "s|^$key=.*|$key=\"$val\"|" "$kv_file"
  else
    echo "$key=\"$val\"" >> "$kv_file"
  fi
}

set_kv_item "$1" "$2"
