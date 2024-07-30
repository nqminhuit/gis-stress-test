#!/bin/bash

function main() {
    podman version
    podman build --build-arg GIS_COMMIT=$1 -f scripts/Containerfile-jar-gis -t build-jar-gis .
    podman kube play --replace --build $2

    printf "\nPlease wait while dataset is being setup...\n"
    podman container wait stress-test-scripts

    printf "\nContainers sizes: \n"
    podman ps -a --pod --size --format "table {{.Names}} {{.Status}} {{.PodName}} {{.Restarts}} {{.Size}}"
    printf "\n"

    podman cp stress-test-scripts:/benchmark-report.md result.md
    podman cp stress-test-scripts:/gis_means _gis_means
    podman cp stress-test-scripts:/gis_st_means _gis_st_means
    podman cp stress-test-scripts:/gis_branches_means _gis_branches_means
    podman cp stress-test-scripts:/gis_branches_nn_means _gis_branches_nn_means
    podman cp stress-test-scripts:/gis_fe_means _gis_fe_means
    podman cp stress-test-scripts:/gis_co_means _gis_co_means
    podman cp stress-test-scripts:/gis_files_means _gis_files_means
    podman cp stress-test-scripts:/gis_versions _gis_versions
    podman logs stress-test-scripts
    podman pod rm -f stress-test

    if [ ! -s result.md ]
    then
        echo "ERROR: Performance result is empty!"
        return 1
    fi

    printf "\nSystem info: " >> result.md
    printf "[Standard GitHub-hosted runners for public repositories]" >> result.md
    printf "(https://docs.github.com/en/actions/using-github-hosted-runners/about-github-hosted-runners/about-github-hosted-runners#standard-github-hosted-runners-for-public-repositories)" >> result.md

    printf "\nResult is saved under $(readlink -f result.md)\n"
}

main $1 $2
