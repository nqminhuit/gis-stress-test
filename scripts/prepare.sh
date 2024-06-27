#!/bin/bash

GITBUCKET_URL="http://localhost:9898"
_GITBUCKET_URL="http://root:root@localhost:9898"
BASIC_AUTH_TOKEN="cm9vdDpyb290" # https://en.wikipedia.org/wiki/Basic_access_authentication

N_REPOS=100
N_FILES=1000
N_BRANCHES=100
N_COMMITS=100
N_MOD_FILES=250

# 1. create root repo and 1000 sub-repos
# 2. for each repo do initial commit and push to master
# 3. for each sub-repo do create 100 commits and push to master
# 4. [100 times] for each repo do create new branch with 1 commit and push

function create_repo() {
    repo_name=$1
    curl -sSL -X POST \
         -H "accept: application/json" \
         -H "authorization: Basic "$BASIC_AUTH_TOKEN \
         $GITBUCKET_URL'/api/v3/user/repos' \
         -d '{"name":"'$repo_name'","private":false}' \
         -o /dev/null
}

function init_commit_and_push_to_master() {
    repo_name=$1
    cd $repo_name
    for i in {1..$N_FILES}
    do {
            shuf /tmp/sigtext-test-stress > text-$i
        }
    done

    git init -q
    git add .
    git commit -q -m "first commit"
    git remote add origin $_GITBUCKET_URL/git/root/$repo_name.git
    git push -q -u origin master
}

function foreach_subrepo_commit_and_push_to_branch() {
    branch=$1
    repos=($(ls -d */))
    for repo in ${repos[@]}
    do {(
           cd $repo
           git checkout -q master
           git checkout -q -b $branch
           scramble_texts

           git add .
           git commit -q -m "commit-$(uuidgen)"
           git push -q -u origin $branch
           git checkout -q master
       )}
    done
}


function scramble_texts() {
    for i in {1..$N_MOD_FILES}
    do {
            shuf /tmp/sigtext-test-stress > text-$i
        }
    done
}

function foreach_subrepo_commits_on_current_branch() {
    repos=($(ls -d */))
    for repo in ${repos[@]}
    do {(
           cd $repo
           for i in {1..$N_COMMITS}
           do {
                   scramble_texts
                   git add .
                   git commit -q -m "commit-$(uuidgen)"
               }
           done
           git push -q
           git prune
           git gc -q
       )}
    done
}

function main() {
    rm -rf /tmp/test-rootrepo
    curl -sSL 'https://en.wikipedia.org/wiki/Plain_text' -o /tmp/sigtext-test-stress

    mkdir /tmp/test-rootrepo; cd /tmp/test-rootrepo
    git config --global user.email "you@example.com"
    git config --global user.name "Your Name"

    # create empty remote git repo
    for i in {1..$N_REPOS}
    do {
            mkdir test-subrepo-$i
            create_repo test-subrepo-$i
        }
    done
    # Done: create empty remote git repo

    # initial commit
    for i in {1..$N_REPOS}
    do {(
           init_commit_and_push_to_master test-subrepo-$i
       )}
    done
    # Done: initial commit

    foreach_subrepo_commits_on_current_branch

    for i in {1..$N_BRANCHES}
    do {(
           foreach_subrepo_commit_and_push_to_branch branch-stresstest-$i
       )}
    done
}

main
