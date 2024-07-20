#!/bin/bash

source ./scripts/common.sh

podman kube play --replace --build small_dataset.yaml

printf "\nPlease wait while dataset is being setup...\n"

run_stress_test
