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
    podman cp stress-test-scripts:/benchmark-report.md result.md
    podman logs stress-test-scripts
    podman pod rm -f stress-test

    printf "\nCPU info:" >> result.md
    printf "\n\`\`\`\n" >> result.md
    lscpu | grep CPU >> result.md
    printf "\`\`\`" >> result.md

    printf "\nResult is saved under $(readlink -f result.md)\n"
}