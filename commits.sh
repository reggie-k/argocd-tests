#!/bin/bash

# Configuration
#TOKEN="your_github_token"          # Replace with your GitHub personal access token
USERS_ARGO_CD=("todaywasawesome" "reggie-k" "revitalbarletz" "kostis-codefresh")
USERS_ARGO_ROLLOUTS=("kostis-codefresh")
START_DATE=$(date -u -v-14d +"%Y-%m-%dT%H:%M:%SZ")  # 14 days ago in UTC
END_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")          # Current date in UTC

# Initialize total commit count
TOTAL_COMMIT_COUNT=0

# Function to fetch and count commits for a given user and repository
fetch_and_count_commits() {
    local USERNAME=$1
    local REPO=$2

    # Fetch commits from the repository in the given date range
    COMMITS_URL="https://api.github.com/repos/$REPO/commits?author=$USERNAME&since=$START_DATE&until=$END_DATE"
    COMMITS=$(curl -s -H "Authorization: token $TOKEN" "$COMMITS_URL")

    # Count the number of commits
    COMMIT_COUNT=$(echo "$COMMITS" | jq -r '. | length')

    # Add to total commit count
    TOTAL_COMMIT_COUNT=$((TOTAL_COMMIT_COUNT + COMMIT_COUNT))

    echo "Commits authored by $USERNAME in $REPO: $COMMIT_COUNT"
}

# Loop through each user for argoproj/argo-cd repository
for USERNAME in "${USERS_ARGO_CD[@]}"; do
    fetch_and_count_commits "$USERNAME" "argoproj/argo-cd"
done

# Loop through each user for argoproj/argo-rollouts repository
for USERNAME in "${USERS_ARGO_ROLLOUTS[@]}"; do
    fetch_and_count_commits "$USERNAME" "argoproj/argo-rollouts"
done

echo "Total commits authored in the last 14 days: $TOTAL_COMMIT_COUNT"