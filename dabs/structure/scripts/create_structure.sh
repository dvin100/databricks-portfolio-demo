#!/bin/bash

# Extract catalog name from databricks.yml
#catalog=$(grep -A 2 "^  catalog:" databricks.yml | grep "default:" | sed 's/.*default: *//' | tr -d ' ')
catalog="test-dvin100-20260102-2"
# Extract schema name from databricks.yml
#schema=$(grep -A 2 "^  schema:" databricks.yml | grep "default:" | sed 's/.*default: *//' | tr -d ' ')
schema="portfolio"
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
echo "Catalog: $catalog"
echo "Schema: $schema"

# Check if catalog exists, create if not
response=$(curl -s -w "\n%{http_code}" -X GET "${workspace_url}/api/2.1/unity-catalog/catalogs/${catalog}" \
  -H "Authorization: Bearer ${token}")

http_code=$(echo "$response" | tail -n1)
response_body=$(echo "$response" | sed '$d')

if [ "$http_code" = "200" ]; then
    echo "Catalog '${catalog}' already exists"
else
    echo "Catalog '${catalog}' not found (HTTP $http_code), creating..."
    
    # Use SQL execution API to create catalog with default storage
    # First, we need to get a SQL warehouse ID
    echo "Attempting to create catalog using SQL execution API..."
    
    # Get SQL warehouses
    warehouses_response=$(curl -s -X GET "${workspace_url}/api/2.0/sql/warehouses" \
      -H "Authorization: Bearer ${token}")
    
    warehouse_id=$(echo "$warehouses_response" | grep -o '"id":"[^"]*' | head -1 | cut -d'"' -f4)
    
    if [ -z "$warehouse_id" ]; then
        echo "Error: Could not find a SQL warehouse. Please create one in the Databricks UI first."
        exit 1
    fi
    
    # Execute SQL to create catalog
    sql_response=$(curl -s -w "\n%{http_code}" -X POST "${workspace_url}/api/2.1/unity-catalog/catalogs" \
      -H "Authorization: Bearer ${token}" \
      -H "Content-Type: application/json" \
      -d "{
        \"name\": \"${catalog}\"
      }")
    
    sql_code=$(echo "$sql_response" | tail -n1)
    sql_body=$(echo "$sql_response" | sed '$d')
    
    if [ "$sql_code" = "200" ]; then
        echo "Catalog '${catalog}' created successfully using SQL"
    else
        echo "Failed to create catalog using SQL. HTTP Code: $sql_code"
        if [ -n "$sql_body" ]; then
            echo "Response: $sql_body"
        fi
        exit 1
    fi
fi


sleep 60

echo "Checking if schema '${catalog}.${schema}' exists..."

# Check if schema exists, create if not
schema_response=$(curl -s -w "\n%{http_code}" -X GET "${workspace_url}/api/2.1/unity-catalog/schemas/${catalog}.${schema}" \
  -H "Authorization: Bearer ${token}")

schema_http_code=$(echo "$schema_response" | tail -n1)
schema_response_body=$(echo "$schema_response" | sed '$d')

if [ "$schema_http_code" = "200" ]; then
    echo "Schema '${catalog}.${schema}' already exists"
else
    echo "Schema '${catalog}.${schema}' not found (HTTP $schema_http_code), creating..."
    
    create_schema_response=$(curl -s -w "\n%{http_code}" -X POST "${workspace_url}/api/2.1/unity-catalog/schemas" \
      -H "Authorization: Bearer ${token}" \
      -H "Content-Type: application/json" \
      -d "{
        \"name\": \"${schema}\",
        \"catalog_name\": \"${catalog}\"
      }")
    
    create_schema_code=$(echo "$create_schema_response" | tail -n1)
    create_schema_body=$(echo "$create_schema_response" | sed '$d')
    
    if [ "$create_schema_code" = "200" ] || [ "$create_schema_code" = "201" ]; then
        echo "Schema '${catalog}.${schema}' created successfully"
    else
        echo "Failed to create schema. HTTP Code: $create_schema_code"
        if [ -n "$create_schema_body" ]; then
            echo "Response: $create_schema_body"
        fi
        exit 1
    fi
fi

# Check if volume "artifacts" exists, create if not
volume_name="artifacts"
volume_response=$(curl -s -w "\n%{http_code}" -X GET "${workspace_url}/api/2.1/unity-catalog/volumes/${catalog}.${schema}.${volume_name}" \
  -H "Authorization: Bearer ${token}")

volume_http_code=$(echo "$volume_response" | tail -n1)
volume_response_body=$(echo "$volume_response" | sed '$d')

if [ "$volume_http_code" = "200" ]; then
    echo "Volume '${catalog}.${schema}.${volume_name}' already exists"
else
    echo "Volume '${catalog}.${schema}.${volume_name}' not found (HTTP $volume_http_code), creating..."
    
    create_volume_response=$(curl -s -w "\n%{http_code}" -X POST "${workspace_url}/api/2.1/unity-catalog/volumes" \
      -H "Authorization: Bearer ${token}" \
      -H "Content-Type: application/json" \
      -d "{
        \"name\": \"${volume_name}\",
        \"catalog_name\": \"${catalog}\",
        \"schema_name\": \"${schema}\",
        \"volume_type\": \"MANAGED\"
      }")
    
    create_volume_code=$(echo "$create_volume_response" | tail -n1)
    create_volume_body=$(echo "$create_volume_response" | sed '$d')
    
    if [ "$create_volume_code" = "200" ] || [ "$create_volume_code" = "201" ]; then
        echo "Volume '${catalog}.${schema}.${volume_name}' created successfully"
    else
        echo "Failed to create volume. HTTP Code: $create_volume_code"
        if [ -n "$create_volume_body" ]; then
            echo "Response: $create_volume_body"
        fi
        exit 1
    fi
fi