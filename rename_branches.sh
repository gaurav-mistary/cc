#!/bin/bash

echo "Starting branch migration..."

# Fetch all local branches, excluding main
branches=$(git for-each-ref --format='%(refname:short)' refs/heads/)

for branch in $branches; do
    if [[ "$branch" == "main" ]]; then
        continue
    fi
    
    # 1. Remove the /scratch suffix if it exists
    new_branch="${branch/\/scratch/}"
    
    # 2. Replace all remaining '/' with '--'
    new_branch="${new_branch//\//--}"
    
    if [[ "$branch" != "$new_branch" ]]; then
        echo "Renaming: '$branch' -> '$new_branch'"
        # Rename the branch locally
        git branch -m "$branch" "$new_branch"
        
        # NOTE: If these branches were already pushed to origin, 
        # you will need to push the new ones and delete the old ones:
        # git push origin -u "$new_branch"
        # git push origin --delete "$branch"
    fi
done

echo "Branch migration complete! Run 'git branch' to verify."
