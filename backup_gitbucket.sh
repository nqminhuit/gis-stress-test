#!/usr/bin/env sh

# ref: https://github.com/gitbucket/gitbucket/wiki/Backup
# bash backup.sh [-v] GITBUCKET_HOME BACKUP_FOLDER GITBUCKET_ROOT_URL GITBUCKET_API_TOKEN
# to import, try this api: https://github.com/gitbucket/gitbucket/blob/a680398c54063654f2c2e56f568fb65768a3f056/src/main/scala/gitbucket/core/controller/FileUploadController.scala#L153
#
# curl 'http://localhost:9898/upload/import' \
#   -X 'POST' \
#   -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8' \
#   -H 'Accept-Language: en-US,en' \
#   -H 'Cache-Control: max-age=0' \
#   -H 'Connection: keep-alive' \
#   -H 'Content-Length: 1735' \
#   -H 'Content-Type: multipart/form-data; boundary=----WebKitFormBoundaryULAzgmAJn2MHpsYl' \
#   -H 'Cookie: metabase.DEVICE=b1e4f17f-1f2e-4d9c-b7c1-9ca5d5cc8eb7; JSESSIONID=node01t686bvpau5ii19zik71bwvcb10.node0' \
#   -H 'Origin: http://localhost:9898' \
#   -H 'Referer: http://localhost:9898/admin/data' \
#   -H 'Sec-Fetch-Dest: document' \
#   -H 'Sec-Fetch-Mode: navigate' \
#   -H 'Sec-Fetch-Site: same-origin' \
#   -H 'Sec-Fetch-User: ?1' \
#   -H 'Sec-GPC: 1' \
#   -H 'Upgrade-Insecure-Requests: 1' \
#   -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36' \
#   -H 'sec-ch-ua: "Not/A)Brand";v="8", "Chromium";v="126", "Brave";v="126"' \
#   -H 'sec-ch-ua-mobile: ?0' \
#   -H 'sec-ch-ua-platform: "Linux"'

DEBUG=0
if [ "$1" = "-v" ]
then
    DEBUG=1
    shift
fi

GITBUCKET_DATA=$1
BACKUP_FOLDER=$2
GITBUCKET_URL=$3
GITBUCKET_TOKEN=$4

GITBUCKET_DB_BACKUP_URL=$3/api/v3/plugins/database/backup

gitbucketRepositoriesFolder=$GITBUCKET_DATA/repositories
repositoriesFolderNameSize=${#gitbucketRepositoriesFolder}

repositoriesBackupFolder=$BACKUP_FOLDER/repositories

##
## trace allows to print messages on the console if -v argument (verbose) has been given to the program
##
function trace {
    if [ "$DEBUG" = "1" ]
    then
        echo "$@"
    fi
}

##
## create a git mirror clone of a repository. If the clone already exists, the operation is skipped
##    arg1: source of the repository to be cloned
##    arg2: full folder name of the clone
##
function createClone {
    source=$1
    dest=$2

    if [ ! -d $dest ]
    then
        trace "  cloning $source into $dest"
        git clone --mirror $source $dest > /dev/null 2>&1
    else
        trace "  $dest already exists, skipping git clone operation"
    fi
}

##
## update a clone folder, the update is down toward the latest state of its default remote
##
function updateRepository {
    currentFolder=$(pwd)
    cd $1
    trace "  updating $1"
    git remote update > /dev/null
    cd $currentFolder
}

# Perform some initializations
if [ ! -d $repositoriesBackupFolder ]
then
    mkdir -p $repositoriesBackupFolder > /dev/null
fi


#
# To keep integrity as its maximum possible, the database export and git backups must be done in the shortest possible timeslot.
# Thus we will:
#   - clone new repositories into backup directory
#   - update them all a first time, so that we gather gib updates
#   - export the database
#   - update all repositories a second time, this time it should be ultra-fast
#

# First let's be sure that all existing directories have a clone
# as clone operation can be heavy let's do it now
repositories=$(find $gitbucketRepositoriesFolder -name *.git -print)

echo "Starting clone process"
for fullRepositoryFolderPath in $repositories
do
    repositoryFolder=${fullRepositoryFolderPath:$repositoriesFolderNameSize}
    mirrorFolder=$repositoriesBackupFolder$repositoryFolder

    createClone $fullRepositoryFolderPath $mirrorFolder
done;
echo "All repositories, cloned"

echo "Update repositories: phase 1"
#
# Then let's update all our clones
#
for fullRepositoryFolderPath in $repositories
do
    repositoryFolder=${fullRepositoryFolderPath:$repositoriesFolderNameSize}
    mirrorFolder=$repositoriesBackupFolder$repositoryFolder

    updateRepository $mirrorFolder
done;
echo "Update repositories: phase 1, terminated"

#
# Export the database
#
if [ "$GITBUCKET_DB_BACKUP_URL" != "" ]
then
    echo "Database backup"
    echo "HTTP POST $GITBUCKET_DB_BACKUP_URL"
    db_backup_zip_name=$(curl --silent --show-error --fail -X POST -H "Authorization: token $GITBUCKET_TOKEN" $GITBUCKET_DB_BACKUP_URL)
    db_backup_zip=$GITBUCKET_DATA/backup/$db_backup_zip_name
    echo "Copying $db_backup_zip to $BACKUP_FOLDER"
    cp $db_backup_zip $BACKUP_FOLDER
else
    echo "No database URL provided, skipping database backup"
fi

#
# Export the GitBucket configuration
#
echo "Configuration backup"
cp $GITBUCKET_DATA/gitbucket.conf $BACKUP_FOLDER > /dev/null

#
# Export the GitBucket data directory (avatars, ...)
#
echo "Avatars backup"
tar -cf $BACKUP_FOLDER/data.tar $GITBUCKET_DATA/data > /dev/null 2>&1
gzip -f $BACKUP_FOLDER/data.tar > /dev/null

#
# Export the gist directory
#
echo "Gist backup"
tar -cf $BACKUP_FOLDER/gist.tar $GITBUCKET_DATA/gist > /dev/null 2>&1
gzip -f $BACKUP_FOLDER/gist.tar > /dev/null

#
# Then let's do a final update
#
echo "Update repositories: phase 2"
for fullRepositoryFolderPath in $repositories
do
    repositoryFolder=${fullRepositoryFolderPath:$repositoriesFolderNameSize}
    mirrorFolder=$repositoriesBackupFolder$repositoryFolder

    updateRepository $mirrorFolder
done;
echo "Update repositories: phase 2, terminated"

echo "Update process ended, backup available under: $BACKUP_FOLDER"
