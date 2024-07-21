#!/bin/bash

source ./scripts/common.sh

podman build --build-arg GIS_COMMIT=$1 -f scripts/Containerfile-jar-gis -t build-jar-gis .
podman kube play --replace --build large_dataset.yaml

printf "\nPlease wait while dataset is being setup...\n"

run_stress_test
