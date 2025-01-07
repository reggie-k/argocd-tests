#!/bin/bash

# Configuration
#TOKEN=""    # Replace with your GitHub personal access token
#USERNAME="kostis-codefresh" # Replace with your GitHub username
USERNAME="reggie-k"
#USERNAME="revitalbarletz"
#USERNAME="todaywasawesome"
#USERNAME="pasha-codefresh"
#REPO="argoproj/argo-rollouts" 
REPO="argoproj/argo-cd" 
           # Replace with the repository (e.g., argo-cd/argo-cd)
START_DATE=$(date -u -v-28d +"%Y-%m-%dT%H:%M:%SZ")  # 14 days ago
END_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")          # Current date

# Fetch all pull requests from the repository
PR_URL="https://api.github.com/repos/$REPO/pulls?state=all&per_page=100"
PRS=$(curl -s -H "Authorization: token $TOKEN" "$PR_URL" | jq -r '.[].url')

REVIEWED_COUNT=0

# Iterate over each PR to fetch reviews
for PR in $PRS; do
  REVIEWS_URL="$PR/reviews"
  REVIEWS=$(curl -s -H "Authorization: token $TOKEN" "$REVIEWS_URL")
  
  # Check if the user has reviewed and filter by date
  REVIEW_MATCH=$(echo "$REVIEWS" | jq -r --arg USERNAME "$USERNAME" --arg START_DATE "$START_DATE" --arg END_DATE "$END_DATE" \
    '.[] | select(.user.login == $USERNAME and (.submitted_at >= $START_DATE and .submitted_at <= $END_DATE))')
  
  if [[ -n "$REVIEW_MATCH" ]]; then
    ((REVIEWED_COUNT++))
  fi
done

echo "Pull requests reviewed: $REVIEWED_COUNT"
