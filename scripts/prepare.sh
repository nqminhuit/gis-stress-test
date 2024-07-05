#!/bin/bash

source ./configs.sh

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
    for i in $(seq 1 $N_FILES)
    do {
            shuf $TEXT_FILE_TMP > text-$i
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


function foreach_subrepo_commits_on_current_branch() {
    repos=($(ls -d */))
    for repo in ${repos[@]}
    do {(
           cd $repo
           for i in $(seq 1 $N_COMMITS)
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
    mkdir $ROOT_MODULE; cd $ROOT_MODULE
    git config --global user.email "you@example.com"
    git config --global user.name "Your Name"

    for i in $(seq 1 30)
    do {
            nc -z localhost $GITBUCKET_PORT || sleep 2;
        }
    done

    # create empty remote git repo
    for i in $(seq 1 $N_REPOS)
    do {
            mkdir $SUB_MODULE_PREFIX$i
            create_repo $SUB_MODULE_PREFIX$i
        }
    done
    # Done: create empty remote git repo

    # initial commit
    for i in $(seq 1 $N_REPOS)
    do {(
           init_commit_and_push_to_master $SUB_MODULE_PREFIX$i
       )}
    done
    # Done: initial commit

    foreach_subrepo_commits_on_current_branch

    for i in $(seq 1 $N_BRANCHES)
    do {(
           foreach_subrepo_commit_and_push_to_branch branch-stresstest-$i
       )}
    done
    echo "done prepare dataset..."
}

main
