#!/bin/bash

args=()

for i in "$@"; do
    if [ $i != "--" ]; then
        args+=("$i")
    fi
done


pwd
echo running: "${args[@]}"
exec "${args[@]}"

