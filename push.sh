#!/bin/bash

REMOTE=origin
BRANCH=$(git rev-parse --abbrev-ref HEAD)
LOCAL_COMMITS=$(git rev-list --count HEAD ^$REMOTE/$BRANCH)
BATCH_SIZE=$((LOCAL_COMMITS / 10 + 1))

# check if the branch exists on the remote
if git show-ref --quiet --verify refs/remotes/$REMOTE/$BRANCH; then
    # if so, only push the commits that are not on the remote already
    range=$REMOTE/$BRANCH..HEAD
    REMOTE_COMMITS=$(git rev-list --count $REMOTE/$BRANCH..HEAD)
else
    # else push all the commits
    range=HEAD
    REMOTE_COMMITS=0
fi
# count the number of commits to push
n=$(git log --first-parent --format=format:x $range | wc -l)

# initialize counter
counter=1

# push each batch
for i in $(seq $n -$BATCH_SIZE 1); do
    # get the hash of the commit to push
    h=$(git log --first-parent --reverse --format=format:%H --skip $i -n1)
    echo "Pushing commit $counter/$LOCAL_COMMITS (remote synced $REMOTE_COMMITS): $h..."
    # push the commit and check the return value
    success=false
    retries=0
    until $success || [ $retries -eq 3 ]; do
        if git push $REMOTE $h:refs/heads/$BRANCH; then
            success=true
        else
            echo "Pushing failed. Retrying..."
            retries=$((retries+1))
            sleep 1
        fi
    done
    # check if the retry count has been exhausted
    if ! $success; then
        echo "Pushing failed. Retry limit exceeded. Aborting."
        exit 1
    fi
    # increment counters
    counter=$((counter+1))
    REMOTE_COMMITS=$((REMOTE_COMMITS+1))
done
# push the final partial batch
success=false
retries=0
until $success || [ $retries -eq 3 ]; do
    if git push $REMOTE HEAD:refs/heads/$BRANCH; then
        success=true
    else
        echo "Pushing failed. Retrying..."
        retries=$((retries+1))
        sleep 1
    fi
done
# check if the retry count has been exhausted
if ! $success; then
    echo "Pushing failed. Retry limit exceeded. Aborting."
    exit 1
fi
echo "Pushing completed successfully."