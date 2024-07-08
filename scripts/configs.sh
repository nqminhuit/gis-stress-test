GITBUCKET_PORT=8080
GITBUCKET_URL="http://localhost:$GITBUCKET_PORT"
_GITBUCKET_URL="http://root:root@localhost:$GITBUCKET_PORT"
BASIC_AUTH_TOKEN="cm9vdDpyb290" # base64 encoded of "root:root". ref: https://en.wikipedia.org/wiki/Basic_access_authentication

ROOT_MODULE="/tmp/test-rootrepo"
SUB_MODULE_PREFIX="test-subrepo-"
TEXT_FILE_TMP="/file_plain_text"

N_REPOS=10
N_FILES=100
N_BRANCHES=10
N_COMMITS=100
N_MOD_FILES=100

function scramble_texts() {
    for i in $(seq 1 $N_MOD_FILES)
    do {
            shuf $TEXT_FILE_TMP > text-$i
        }
    done
}
