#!/usr/bin/env bash

export TESTS_DIR="$(realpath "$(dirname "$0")")"

for layout in "$TESTS_DIR"/symbols/*; do
    [ -d "$layout" ] && continue
    xkbcli compile-keymap \
        --include "$TESTS_DIR" \
        --include /tmp/xkb \
        --include-defaults \
        --test \
        --layout "$layout" \
        --variant test &&  \
        echo "Valid :)      $(basename "$layout")" || \
        echo "Invalid! :(   $(basename "$layout")"
done
