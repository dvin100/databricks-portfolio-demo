#!/bin/bash

# Get the script directory and find databricks.yml
databricks_yml="../databricks.yml"
# Extract catalog name from databricks.yml
catalog=$(grep -A 2 "^  catalog:" "$databricks_yml" | grep "default:" | sed 's/.*default: *//' | tr -d ' ')

# Extract schema name from databricks.yml
schema=$(grep -A 2 "^  schema:" "$databricks_yml" | grep "default:" | sed 's/.*default: *//' | tr -d ' ')

# Extract sql_warehouse ID from databricks.yml
sql_warehouse=$(grep -A 2 "^  sql_warehouse:" "$databricks_yml" | grep "default:" | sed 's/.*default: *//' | tr -d ' ')

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

# Build the serialized_space JSON with proper variable expansion
serialized_space_json=$(cat <<EOF
{
  "version": 1,
  "config": {
    "sample_questions": [{
      "question": ["Show me the portfolio value"]
    }]
  },
  "data_sources": {
    "tables": [
      {"identifier": "${catalog}.${schema}.company_stocks"},
      {"identifier": "${catalog}.${schema}.portfolio_value"},
      {"identifier": "${catalog}.${schema}.ticker"}
    ]
  }
}
EOF
)

# Build the genie_config using jq - Must be installed on the machine.
# Compact the JSON
serialized_space_compact=$(echo "$serialized_space_json" | jq -c .)
# Build the final config - jq will properly escape the string when using --arg
genie_config=$(jq -n \
    --arg desc "This genie space is for the portfolio dashboard and provides insights for the portfolio" \
    --arg path "/Workspace/Users/david.vincent@databricks.com/" \
    --arg space "$serialized_space_compact" \
    --arg title "Genie Portfolio" \
    --arg warehouse "$sql_warehouse" \
    '{description: $desc, parent_path: $path, serialized_space: $space, title: $title, warehouse_id: $warehouse}')


# Display the config in multi-line format
echo "Genie Config:"
echo "$genie_config" | jq .

response=$(curl -s -w "\n%{http_code}" -X POST "${workspace_url}/api/2.0/genie/spaces" \
          -H "Authorization: Bearer ${token}" \
          -H "Content-Type: application/json" \
          -d "${genie_config}")

# Split response body and HTTP status code
http_code=$(echo "$response" | tail -n1)
response_body=$(echo "$response" | sed '$d')

echo "Response Body:"
echo "$response_body" | jq . 2>/dev/null || echo "$response_body"
echo ""
echo "HTTP Status Code: $http_code"

# Try to extract space_id from response (even if HTTP status is not 200/201)
# Try multiple possible field names
space_id=$(echo "$response_body" | jq -r '.id // .space_id // .spaceId // empty' 2>/dev/null)

# If still empty, try to parse as JSON and look for id field anywhere
if [ -z "$space_id" ] || [ "$space_id" = "null" ] || [ "$space_id" = "empty" ]; then
    # Try to find any "id" field in the JSON
    space_id=$(echo "$response_body" | jq -r 'if type == "object" then .id // empty else empty end' 2>/dev/null)
fi

if [ -n "$space_id" ] && [ "$space_id" != "null" ] && [ "$space_id" != "empty" ]; then
    echo "Space ID extracted: $space_id"
    
    # Update Portfolio.lvdash.json with the new space_id
    dashboard_json="../fixtures/dashboard/Portfolio.lvdash.json"
    
    if [ -f "$dashboard_json" ]; then
        # Use jq to update the overrideId
        if jq --arg space_id "$space_id" '.uiSettings.genieSpace.overrideId = $space_id' "$dashboard_json" > "${dashboard_json}.tmp" 2>/dev/null; then
            mv "${dashboard_json}.tmp" "$dashboard_json"
            echo "✓ Updated Portfolio.lvdash.json with space_id: $space_id"
        else
            echo "Error: Failed to update dashboard JSON file"
            rm -f "${dashboard_json}.tmp"
            exit 1
        fi
    else
        echo "Warning: Dashboard JSON file not found at $dashboard_json"
        exit 1
    fi
    
    # Warn if HTTP status was not success, but still proceed since we got the space_id
    if [ "$http_code" -ne 200 ] && [ "$http_code" -ne 201 ]; then
        echo "Warning: HTTP status code was $http_code, but space_id was successfully extracted"
    fi
else
    echo "Error: Could not extract space_id from response"
    echo "Response body was:"
    echo "$response_body"
    exit 1
fi

