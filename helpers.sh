#!/usr/bin/env bash

dirslug() {
    str="$1"
    str="$(echo "${str,,}" | sed -E 's/[ -\/]+/_/g')"
    echo $str
}

fileslug() {
    str="$1"
    str="$(echo "$str" | sed -E 's/[ -\/]+/_/g')"
    echo $str
}

lower() {
    echo "${1,,}"
}

confirm() {
    local rule="$1"
    local input="$(lower "$2")"

    if [[ "$#" -lt 2 ]]; then
        echo "error: 'confirm' function must have two arguments: rule (.e.g 'y/N') and input (.e.g 'n')"
        exit 1
    fi

    if [[ $input = 'q' ]]; then
        print_config
        echo "Quitting early..."
        exit 0
    fi

    if [[ $rule = "y/n" || $rule = "y/N" ]]; then
        if [[ $input = "y" ]]; then
            echo 'y'; return 0
        fi

        # If input is left blank, then choose Default
        if [[ -z $input || $input = 'n' ]]; then
            echo 'n'; return 0
        fi
    fi

    if [[ $rule = "Y/n" ]]; then
        if [[ $input = "n" ]]; then
            echo 'n'; return 0
        fi

        # If input is left blank, then choose Default
        if [[ -z $input || $input = 'y' ]]; then
            echo 'y'; return 0
        fi
    fi
}

set_kv_item() {
    local key="$1"
    local val="$2"
    local kv_file="$3"

    if [[ "$#" -lt 3 ]]; then
        echo "set_kv_item() error. Usage: set_kv_item <key> <value> <kv_file>"
    fi

    if [[ ! -f "$kv_file" ]]; then
        touch "$kv_file"
    fi

    if grep -q "^$key=" "$kv_file"; then
        sed -i "s|^$key=.*|$key=\"$val\"|" "$kv_file"
    else
        echo "$key=\"$val\"" >> "$kv_file"
    fi
}
