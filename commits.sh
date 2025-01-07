#!/bin/bash

# Configuration
#TOKEN="your_github_token"          # Replace with your GitHub personal access token
#USERNAME="todaywasawesome"  
#USERNAME="reggie-k"
#USERNAME="revitalbarletz"
#USERNAME="kostis-codefresh" 
USERNAME="pasha-codefresh" # Replace with your GitHub username
REPO="argoproj/argo-cd"                  # Replace with the repository (e.g., argo-cd/argo-cd)
#REPO="argoproj/argo-rollouts" 
START_DATE=$(date -u -v-28d +"%Y-%m-%dT%H:%M:%SZ")  # 14 days ago in UTC
END_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")          # Current date in UTC

# Fetch commits from the repository in the given date range
COMMITS_URL="https://api.github.com/repos/$REPO/commits?author=$USERNAME&since=$START_DATE&until=$END_DATE"
COMMITS=$(curl -s -H "Authorization: token $TOKEN" "$COMMITS_URL" | jq -r '.[]')

# Count the number of commits
COMMIT_COUNT=$(echo "$COMMITS" | jq -r '. | length')

echo "Commits authored in the last week: $COMMIT_COUNT"
