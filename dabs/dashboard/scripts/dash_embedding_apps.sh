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


response=$(curl -s -w "\n%{http_code}" -X GET "${workspace_url}/api/2.0/lakeview/dashboards" \
-H "Authorization: Bearer ${token}")

http_code=$(echo "$response" | tail -n1)
response_body=$(echo "$response" | sed '$d')

echo "Response body: $response_body"

# Extract dashboard_id for display_name ending with "Portfolio Dashboard"
if command -v jq &> /dev/null; then
    dashboard_id=$(echo "$response_body" | jq -r '.dashboards[]? | select(.display_name | endswith("Portfolio Dashboard")) | .dashboard_id' | head -1)
else
    # Fallback using grep/awk if jq is not available
    dashboard_id=$(echo "$response_body" | grep -o '"display_name": "[^"]*Portfolio Dashboard"' -A 5 | grep -o '"dashboard_id": "[^"]*' | head -1 | cut -d'"' -f4)
fi

if [ -n "$dashboard_id" ]; then
    echo "Found dashboard_id: $dashboard_id"
    echo "Replacing iframe src URL with $workspace_url/embed/dashboardsv3/$dashboard_id in the apps/src/client/src/pages/DashboardPage.tsx file"
    sed -i '' 's|<iframe src="[^"]*"|<iframe src="'"$workspace_url/embed/dashboardsv3/$dashboard_id"'"|g' ../../apps/src/client/src/pages/DashboardPage.tsx
else
    echo "Warning: Could not find dashboard with display_name ending with 'Portfolio Dashboard'"
fi


# Extract dashboard_id for display_name ending with "News Dashboard"
if command -v jq &> /dev/null; then
    dashboard_id=$(echo "$response_body" | jq -r '.dashboards[]? | select(.display_name | endswith("News Dashboard")) | .dashboard_id' | head -1)
else
    # Fallback using grep/awk if jq is not available
    dashboard_id=$(echo "$response_body" | grep -o '"display_name": "[^"]*News Dashboard"' -A 5 | grep -o '"dashboard_id": "[^"]*' | head -1 | cut -d'"' -f4)
fi

if [ -n "$dashboard_id" ]; then
    echo "Found dashboard_id: $dashboard_id"
    echo "Replacing iframe src URL with $workspace_url/embed/dashboardsv3/$dashboard_id in the apps/src/client/src/pages/NewsPage.tsx file"
    sed -i '' 's|<iframe src="[^"]*"|<iframe src="'"$workspace_url/embed/dashboardsv3/$dashboard_id"'"|g' ../../apps/src/client/src/pages/NewsPage.tsx
else
    echo "Warning: Could not find dashboard with display_name ending with 'News Dashboard'"
fi