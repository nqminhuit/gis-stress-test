#!/usr/bin/env sh

source scripts/configs.sh

podman build -q -f scripts/Containerfile-prepare -t gis-stress-test-prepare
podman build -q --no-cache -f scripts/Containerfile-benchmark -t gis-stress-test-benchmark

gis_volume=/tmp/gis-stress-test/$N_REPOS.$N_FILES.$N_BRANCHES.$N_COMMITS.$N_MOD_FILES
if [[ ! -d $gis_volume ]]
then
    echo "gitbucket dataset not exist, creating new one"
    mkdir -p $gis_volume
    printf "
apiVersion: v1
kind: Pod
metadata:
  name: gis-stress-test-prepare
spec:
  restartPolicy: Never
  containers:
  - name: gitbucket
    image: ghcr.io/gitbucket/gitbucket:4.39.0
    ports:
    - containerPort: 8080
      hostPort: 9898
  - name: scripts
    image: localhost/scripts
" | podman kube play --replace --build -
podman container wait stress-test-scripts
podman cp stress-test-scripts:/benchmark-report.md result.md
podman logs stress-test-scripts
podman pod rm -f stress-test

printf "\nCPU info:" >> result.md
printf "\n\`\`\`\n" >> result.md
lscpu | grep CPU >> result.md
printf "\`\`\`" >> result.md

printf "\nResult is saved under $(readlink -f result.md)\n"
