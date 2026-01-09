#!/bin/bash

# Script to create a SQL warehouse and update databricks.yml with the warehouse ID

# Get the directory where the script is located
DATABRICKS_YML="../databricks.yml"

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

warehouse_name="sql_warehouse"

# Check if warehouse already exists
echo "Checking if warehouse '$warehouse_name' already exists..."
warehouses_response=$(curl -s -X GET "${workspace_url}/api/2.0/sql/warehouses" \
      -H "Authorization: Bearer ${token}")

if command -v jq &> /dev/null; then
    warehouse_id=$(echo "$warehouses_response" | jq -r ".warehouses[]? | select(.name == \"$warehouse_name\") | .id // empty" | head -1)
else
    # Fallback: use grep to find warehouse by name and extract ID
    # This is more complex without jq, so we'll search for the pattern
    warehouse_id=$(echo "$warehouses_response" | grep -A 10 "\"name\":\"$warehouse_name\"" | grep -o '"id":"[^"]*' | head -1 | cut -d'"' -f4)
fi

if [ -n "$warehouse_id" ]; then
    echo "Warehouse '$warehouse_name' already exists with ID: $warehouse_id"
    echo "Skipping creation and updating databricks.yml with existing warehouse ID."
else
    echo "Warehouse '$warehouse_name' not found. Creating new warehouse..."
    
    warehouse_config="{\"name\":\"${warehouse_name}\",\"warehouse_type\":\"PRO\",\"enable_serverless_compute\":true,\"cluster_size\":\"Small\",\"min_num_clusters\":1,\"max_num_clusters\":3,\"auto_stop_mins\":10}"

    response=$(curl -s -w "\n%{http_code}" -X POST "${workspace_url}/api/2.0/sql/warehouses" \
          -H "Authorization: Bearer ${token}" \
          -H "Content-Type: application/json" \
          -d "${warehouse_config}")

    http_code=$(echo "$response" | tail -n1)
    response_body=$(echo "$response" | sed '$d')

    echo "HTTP Status Code: $http_code"
    echo "Response: $response_body"

    if [ "$http_code" != "200" ] && [ "$http_code" != "201" ]; then
        echo "Error: Failed to create SQL warehouse. HTTP Code: $http_code"
        exit 1
    fi

    # Extract warehouse_id from the response
    if command -v jq &> /dev/null; then
        warehouse_id=$(echo "$response_body" | jq -r '.id // empty')
    else
        warehouse_id=$(echo "$response_body" | grep -o '"id":"[^"]*' | head -1 | cut -d'"' -f4)
    fi

    if [ -z "$warehouse_id" ]; then
        echo "Error: Could not extract warehouse_id from response"
        exit 1
    fi

    echo "SQL warehouse created successfully! Warehouse ID: $warehouse_id"
fi

# Update warehouse permissions to allow all users to use it
echo "Updating warehouse permissions to grant all users access..."
permissions_config='{"access_control_list":[{"group_name":"users","permission_level":"CAN_USE"}]}'

permissions_response=$(curl -s -w "\n%{http_code}" -X PATCH "${workspace_url}/api/2.0/permissions/warehouses/${warehouse_id}" \
      -H "Authorization: Bearer ${token}" \
      -H "Content-Type: application/json" \
      -d "${permissions_config}")

permissions_http_code=$(echo "$permissions_response" | tail -n1)
permissions_body=$(echo "$permissions_response" | sed '$d')

echo "Permissions HTTP Status Code: $permissions_http_code"
echo "Permissions Response: $permissions_body"

if [ "$permissions_http_code" != "200" ] && [ "$permissions_http_code" != "201" ]; then
    echo "Warning: Failed to update SQL warehouse permissions. HTTP Code: $permissions_http_code"
    echo "Continuing with databricks.yml update..."
else
    echo "Successfully granted CAN_USE permission to all users"
fi

# Update databricks.yml with the warehouse_id
if [ ! -f "$DATABRICKS_YML" ]; then
    echo "Warning: databricks.yml not found at $DATABRICKS_YML"
    echo "Warehouse ID: $warehouse_id"
    exit 0
fi

echo "Updating databricks.yml with warehouse ID: $warehouse_id"

# Create a backup of the original file
cp "$DATABRICKS_YML" "${DATABRICKS_YML}.bak"

# Use awk to update the default value
awk -v new_val="$warehouse_id" '
    /^  sql_warehouse:/ {
        in_section=1
        print
        next
    }
    in_section && /^    default:/ {
        print "    default: " new_val
        next
    }
    /^  [a-z_]+:/ && !/^  sql_warehouse:/ {
        in_section=0
    }
    { print }
' "$DATABRICKS_YML" > "${DATABRICKS_YML}.tmp"

# Check if awk succeeded
if [ $? -eq 0 ]; then
    mv "${DATABRICKS_YML}.tmp" "$DATABRICKS_YML"
    echo "Successfully updated sql_warehouse default value to: $warehouse_id"
    echo "Backup saved to: ${DATABRICKS_YML}.bak"
else
    echo "Error: Failed to update databricks.yml"
    # Restore backup on error
    rm -f "${DATABRICKS_YML}.tmp"
    mv "${DATABRICKS_YML}.bak" "$DATABRICKS_YML"
    exit 1
fi