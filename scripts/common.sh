GITBUCKET_PORT=8080
GITBUCKET_URL="http://localhost:$GITBUCKET_PORT"
_GITBUCKET_URL="http://root:root@localhost:$GITBUCKET_PORT"
BASIC_AUTH_TOKEN="cm9vdDpyb290" # base64 encoded of "root:root". ref: https://en.wikipedia.org/wiki/Basic_access_authentication

ROOT_MODULE="/tmp/test-rootrepo"
SUB_MODULE_PREFIX="test-subrepo-"
TEXT_FILE_TMP="/file_plain_text"

function scramble_texts() {
    for i in $(seq 1 $N_MOD_FILES)
    do {
            shuf $TEXT_FILE_TMP > text-$i
        }
    done
}

function run_stress_test() {
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
