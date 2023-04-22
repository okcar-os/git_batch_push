#!/bin/bash

coloredEcho () {
    local color=$1
    shift
    printf "$(tput bold)$(tput setaf $color)%s$(tput sgr0)\n" "$@"
}

pushCommits () {
    local remote=$1
    local branch=$2
    local range=$3
    local batch_size=$4
    local local_commits=$5
    local remote_commits=$6
    local counter=1
    local retries=3

    # push each batch
    for i in $(seq $local_commits -$batch_size 1); do
        # get the hash of the commit to push
        local h=$(git log --first-parent --reverse --format=format:%H --skip $i -n1)
        coloredEcho 6 "Pushing commit $counter/$local_commits (remote synced $remote_commits): $h..."

        # push the commit and check the return value
        success=false
        while ! $success && [ $retries -gt 0 ]; do
            if git push --force-with-lease $remote $h:refs/heads/$branch; then
                success=true
            else
                coloredEcho 1 "Pushing failed. Retrying..."
                retries=$((retries-1))
                sleep 1
            fi
        done

        # check if the retry count has been exhausted
        if ! $success; then
            coloredEcho 1 "Pushing failed. Aborting."
            exit 1
        fi

        # increment counters
        counter=$((counter+1))
        remote_commits=$((remote_commits+1))
        retries=3
    done

    # push the final partial batch
    success=false
    while ! $success && [ $retries -gt 0 ]; do
        if git push --force-with-lease $remote HEAD:refs/heads/$branch; then
            success=true
        else
            coloredEcho 1 "Pushing failed. Retrying..."
            retries=$((retries-1))
            sleep 1
        fi
    done

    # check if the retry count has been exhausted
    if ! $success; then
        coloredEcho 1 "Pushing failed. Aborting."
        exit 1
    fi

    coloredEcho 2 "Pushing completed successfully."
}

# Check if git is installed
if ! command -v git &> /dev/null; then
    coloredEcho 1 "Git is not installed. Aborting."
    exit 1
fi

REMOTE=origin
BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Check if the branch exists on the remote
if git show-ref --quiet --verify refs/remotes/$REMOTE/$BRANCH; then
    # If so, only push the commits that are not on the remote already
    RANGE=$REMOTE/$BRANCH..HEAD
    REMOTE_COMMITS=$(git rev-list --count $REMOTE/$BRANCH..HEAD)
else
    # Else push all the commits
    RANGE=HEAD
    REMOTE_COMMITS=0
fi

LOCAL_COMMITS=$(git rev-list --count HEAD ^$REMOTE/$BRANCH)

# Count the number of commits to push
N=$(git log --first-parent --format=format:x $RANGE | wc -l)

# Calculate the batch size
BATCH_SIZE=$((LOCAL_COMMITS / 10 + 1))

coloredEcho 2 "REMOTE:$RANGE BATCH_SIZE:$BATCH_SIZE"

# push the commits
pushCommits $REMOTE $BRANCH $RANGE $BATCH_SIZE $LOCAL_COMMITS $REMOTE_COMMITS
