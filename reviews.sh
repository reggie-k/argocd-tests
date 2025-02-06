#!/bin/bash

# Configuration
#TOKEN="your_github_token"    # Replace with your GitHub personal access token
USERS_ARGO_CD=("reggie-k" "revitalbarletz" "todaywasawesome" "pasha-codefresh")
USER_ARGO_ROLLOUTS="kostis-codefresh"
REPO_ARGO_CD="argoproj/argo-cd"
REPO_ARGO_ROLLOUTS="argoproj/argo-rollouts"
START_DATE=$(date -u -v-14d +"%Y-%m-%dT%H:%M:%SZ")  # 14 days ago in UTC
END_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")          # Current date in UTC

# Function to count reviews for a given user and repository
count_reviews() {
    local USERNAME=$1
    local REPO=$2

    # Fetch all PRs in the repository
    PRS=$(curl -s -H "Authorization: token $TOKEN" "https://api.github.com/repos/$REPO/pulls?state=all&per_page=100")

    # Initialize review count
    REVIEW_COUNT=0

    # Iterate over each PR
    for PR_NUMBER in $(echo "$PRS" | jq -r '.[].number'); do
        # Fetch reviews for the PR
        REVIEWS=$(curl -s -H "Authorization: token $TOKEN" "https://api.github.com/repos/$REPO/pulls/$PR_NUMBER/reviews")

        # Count reviews by the user within the date range
        COUNT=$(echo "$REVIEWS" | jq -r --arg USERNAME "$USERNAME" --arg START_DATE "$START_DATE" --arg END_DATE "$END_DATE" '
            map(select(.user.login == $USERNAME and (.submitted_at >= $START_DATE and .submitted_at <= $END_DATE))) | length')

        # Add to the total review count
        REVIEW_COUNT=$((REVIEW_COUNT + COUNT))
    done

    echo "Pull requests reviewed by $USERNAME in $REPO: $REVIEW_COUNT"
}

# Count reviews for the user in argoproj/argo-rollouts
count_reviews "$USER_ARGO_ROLLOUTS" "$REPO_ARGO_ROLLOUTS"

# Count reviews for each user in argoproj/argo-cd
for USERNAME in "${USERS_ARGO_CD[@]}"; do
    count_reviews "$USERNAME" "$REPO_ARGO_CD"
done