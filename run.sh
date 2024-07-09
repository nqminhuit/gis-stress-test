#!/usr/bin/env sh

printf "
apiVersion: v1
kind: Pod
metadata:
  name: stress-test
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
