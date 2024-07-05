#!/bin/bash

source ./configs.sh

function benchmark_gis_files() {
    for i in $(seq 1 $N_REPOS)
    do {(
           cd $SUB_MODULE_PREFIX$i
           scramble_texts
       )}
    done
    hyperfine -r 100 -u millisecond --warmup 15 'gis files' -n 'files' --export-json perf_gis_files.json
    for i in $(seq 1 $N_REPOS)
    do {(
           cd $SUB_MODULE_PREFIX$i
           git restore .
       )}
    done
}

function count_total_branches() {
    for i in $(seq 1 $N_REPOS)
    do {(
           cd $SUB_MODULE_PREFIX$i
           git branch -r | wc -l
       )}
    done
}

function count_total_files() {
    for i in $(seq 1 $N_REPOS)
    do {(
           cd $SUB_MODULE_PREFIX$i
           ls -l | wc -l
       )}
    done
}

function count_total_commits() {
    for i in $(seq 1 $N_REPOS)
    do {(
           cd $SUB_MODULE_PREFIX$i
           git rev-list --count --all
       )}
    done
}

function avg_branches() {
    local array=( $(count_total_branches) )
    local n=${#array[@]}
    local sum=0
    for i in "${array[@]}"
    do
        sum=$((sum + i))
    done
    local avg=$(echo $sum / $n | bc -l)
    printf '%0.3f\n' "$avg"
}

function avg_files() {
    local array=( $(count_total_files) )
    local n=${#array[@]}
    local sum=0
    for i in "${array[@]}"
    do
        sum=$((sum + i))
    done
    local avg=$(echo $sum / $n | bc -l)
    printf '%0.3f\n' "$avg"
}

function avg_commits() {
    local array=( $(count_total_commits) )
    local n=${#array[@]}
    local sum=0
    for i in "${array[@]}"
    do
        sum=$((sum + i))
    done
    local avg=$(echo $sum / $n | bc -l)
    printf '%0.3f\n' "$avg"
}

function main() {
    mkdir $ROOT_MODULE; cd $ROOT_MODULE
    for i in $(seq 1 30)
    do {
            nc -z localhost $GITBUCKET_PORT || sleep 2;
        }
    done

    for i in $(seq 1 $N_REPOS)
    do {(
           git clone $_GITBUCKET_URL/git/root/$SUB_MODULE_PREFIX$i.git
       )}
    done
    gis init

    hyperfine -r 100 -u millisecond --warmup 15 'gis' --export-json perf_gis.json
    hyperfine -r 100 -u millisecond --warmup 15 'gis status' -n 'status' --export-json perf_gis_st.json
    hyperfine -r 100 -u millisecond --warmup 15 'gis branches' -n 'branches' --export-json perf_gis_branches.json
    hyperfine -r 100 -u millisecond --warmup 15 'gis branches -nn' -n 'branches_no_modules' --export-json perf_gis_branches_nn.json
    hyperfine -r 100 -u millisecond --warmup 15 'gis fetch' -n 'fetch' --export-json perf_gis_fe.json
    hyperfine -r 100 -u millisecond --warmup 15 --prepare 'gis co master' --cleanup 'gis co master' 'gis co br_tst_1' -n 'checkout' --export-json perf_gis_co.json
    benchmark_gis_files

    touch benchmark-report.md
    echo "Performance is run with:" >> benchmark-report.md
    echo "- number of submodules: \`$N_REPOS\`" >> benchmark-report.md
    echo "- number of branch per submodules: \`$N_BRANCHES\`" >> benchmark-report.md
    echo "- number of files per submodules: \`$N_FILES\`" >> benchmark-report.md
    echo "- number of commit per submodules: \`$N_COMMITS\`" >> benchmark-report.md
    echo "- each file size: \`$(du -sh $TEXT_FILE_TMP | awk '{ print $1 }')\`" >> benchmark-report.md
    printf "\n\`\`\`\n" >> benchmark-report.md
    echo "command min(ms) mean(ms) max(ms)" | awk '{ $1 = sprintf("%-20s", $1); $2 = sprintf("%-8s", $2); $3 = sprintf("%-8s", $3); $4 = sprintf("%-8s", $4) } 1' >> benchmark-report.md
    ls -1 *.json | xargs -I {} jq -Mcr '.results | .[] | "\(.command) \(.min | .*1000|round/1) \(.mean | .*1000|round/1) \(.max | .*1000|round/1)"' {} | awk '{ $1 = sprintf("%-20s", $1); $2 = sprintf("%-8s", $2); $3 = sprintf("%-8s", $3); $4 = sprintf("%-8s", $4) } 1' >> benchmark-report.md
    printf "\`\`\`" >> benchmark-report.md
    printf "\n\n" >> benchmark-report.md
    printf "gis version: \`$(gis --version)\`\n" >> benchmark-report.md
    printf "git version: \`$(git --version)\`\n" >> benchmark-report.md
    printf "hyperfine version: \`$(hyperfine --version)\`\n" >> benchmark-report.md
    mv benchmark-report.md /benchmark-report.md
}

main
