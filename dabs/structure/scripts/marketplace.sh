#!/bin/bash

# Get workspace URL from .databrickscfg file (first host entry under [DEMO])
workspace_url=$(grep -A 5 "\[DEMO\]" ~/.databrickscfg | grep "^host" | head -1 | awk -F'=' '{print $2}' | tr -d ' ')

# Get token using Databricks CLI (works with OAuth)
export DATABRICKS_CONFIG_PROFILE='DEMO'
if command -v jq &> /dev/null; then
    token=$(databricks auth token --profile DEMO 2>/dev/null | jq -r '.access_token')
else
    token=$(databricks auth token --profile DEMO 2>/dev/null | grep -o '"access_token": "[^"]*' | cut -d'"' -f4)
fi

if [ -z "$workspace_url" ] || [ -z "$token" ]; then
    echo "Error: Could not retrieve workspace URL or token"
    echo "Workspace URL: ${workspace_url:-NOT FOUND}"
    echo "Token: ${token:+FOUND}"
    exit 1
fi

echo "Workspace URL: $workspace_url"
echo "Checking for marketplace catalog 'news'..."

# Check if catalog exists, create if not
while true; do
    response=$(curl -s -w "\n%{http_code}" -X GET "${workspace_url}/api/2.1/unity-catalog/catalogs/news" \
    -H "Authorization: Bearer ${token}")

    http_code=$(echo "$response" | tail -n1)
    response_body=$(echo "$response" | sed '$d')

    if [ "$http_code" = "200" ]; then
        echo "Marketplace catalog 'news' found..."
        break
    else
        echo "Marketplace catalog 'news' not found (HTTP $http_code)..."
        echo ''
        echo "!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-"
        echo "ACTION REQUIRED: manually create the marketplace tables called 'news' from the UI"
        echo "!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-"
        echo ''
        echo "Confirm action completion by hitting ENTER to continue"
        read user_input
    fi
done