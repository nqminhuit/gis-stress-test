#!/bin/bash

source ./configs.sh

benchmark_gis_files() {
    for i in $(seq 1 $N_REPOS)
    do {(
           cd $SUB_MODULE_PREFIX$i
           scramble_texts
       )}
    done
    hyperfine -u millisecond --warmup 5 'gis files' -n 'files' --export-json perf_gis_files.json
    for i in $(seq 1 $N_REPOS)
    do {(
           cd $SUB_MODULE_PREFIX$i
           git restore .
       )}
    done
}

count_total_branches() {
    for i in $(seq 1 $N_REPOS)
    do {(
           cd $SUB_MODULE_PREFIX$i
           git branch -r | wc -l
       )}
    done
}

count_total_files() {
    for i in $(seq 1 $N_REPOS)
    do {(
           cd $SUB_MODULE_PREFIX$i
           ls -l | wc -l
       )}
    done
}

count_total_commits() {
    for i in $(seq 1 $N_REPOS)
    do {(
           cd $SUB_MODULE_PREFIX$i
           git rev-list --count --all
       )}
    done
}

avg_branches() {
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

avg_files() {
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

avg_commits() {
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

cd $ROOT_MODULE
gis init
# git init

hyperfine -u millisecond --warmup 5 'gis' --export-json perf_gis.json
hyperfine -u millisecond --warmup 5 'gis status' -n 'status' --export-json perf_gis_st.json
hyperfine -u millisecond --warmup 5 'gis branches' -n 'branches' --export-json perf_gis_branches.json
hyperfine -u millisecond --warmup 5 'gis branches -nn' -n 'branches_no_modules' --export-json perf_gis_branches_nn.json
hyperfine -u millisecond --warmup 5 'gis fetch' -n 'fetch' --export-json perf_gis_fe.json
hyperfine -u millisecond --warmup 5 --prepare 'gis co master' --cleanup 'gis co master' 'gis co br_tst_1' -n 'checkout' --export-json perf_gis_co.json
benchmark_gis_files
# ls -1 perf*.org | xargs -I {} tail -n 1 {} >> gis_commands_performance.org
# sed -i 's/=//g' gis_commands_performance.org

printf "\n\n"
echo "====================== POST REPORT ======================"
echo "Performance is run with:"
echo "- number of submodules: \`$N_REPOS\`"
echo "- number of branch per submodules: \`$N_BRANCHES\`"
echo "- number of files per submodules: \`$N_FILES\`"
echo "- number of commit per submodules: \`$N_COMMITS\`"
echo "- each file size: \`$(du -sh $TEXT_FILE_TMP | awk '{ print $1 }')\`"

printf "\n\n"
echo "command min(ms) mean(ms) max(ms)" | awk '{ $1 = sprintf("%-20s", $1); $2 = sprintf("%-8s", $2); $3 = sprintf("%-8s", $3); $4 = sprintf("%-8s", $4) } 1'
ls -1 *.json | xargs -I {} jq -Mcr '.results | .[] | "\(.command) \(.min | .*1000|round/1) \(.mean | .*1000|round/1) \(.max | .*1000|round/1)"' {} | awk '{ $1 = sprintf("%-20s", $1); $2 = sprintf("%-8s", $2); $3 = sprintf("%-8s", $3); $4 = sprintf("%-8s", $4) } 1'
rm -rf perf_gis.json perf_gis_st.org perf_gis_branches.org perf_gis_branches_nn.org perf_gis_fe.org perf_gis_files.org perf_gis_co.org

printf "\n\n"
printf "gis version: \`$(gis --version)\`\n"
printf "git version: \`$(git --version)\`\n"
printf "hyperfine version: \`$(hyperfine --version)\`\n"
