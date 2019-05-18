#!/bin/bash

# export data with watchme
mkdir -p "export"

for folder in $(watchme list singularity-pull); do
    if [[ "${folder}" == *"decorator"* ]]; then
        watchme export singularity-pull $folder result.json --force --out export/$folder.json
    fi
done
