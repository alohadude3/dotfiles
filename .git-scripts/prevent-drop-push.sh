#!/bin/bash

# pre-push hook to prevent pushing commits with "[Drop]" in the message

# Read the standard input provided by Git on push
while read local_ref local_sha remote_ref remote_sha
do
    # If the remote SHA is all zeros, it means we are pushing a new branch.
    # We need to check all commits that are not already on the remote.
    if [ "$remote_sha" = "0000000000000000000000000000000000000000" ]; then
        commit_range="$local_sha --not --remotes"
    else
        # Otherwise, check the commits between what the remote has and what we are pushing
        commit_range="$remote_sha..$local_sha"
    fi

    # Get the list of commit hashes in the range
    commits=$(git rev-list $commit_range 2>/dev/null)

    # Loop through each commit being pushed
    for commit in $commits; do
        # Extract the commit message
        commit_message=$(git log --format=%B -n 1 "$commit")

        # Check if the message contains exactly "[Drop]"
        if [[ "$commit_message" == *"[Drop]"* ]]; then
            echo "========================================================="
            echo "🛑 PUSH REJECTED: Temporary commit detected."
            echo "========================================================="
            echo "Commit: $commit"
            echo "Message: $(git log --format=%s -n 1 "$commit")"
            echo ""
            echo "This commit contains '[Drop]'. Please squash, amend,"
            echo "or drop this commit via interactive rebase before pushing."
            echo "========================================================="
            exit 1
        fi
    done
done

exit 0
