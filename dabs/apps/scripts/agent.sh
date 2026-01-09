#!/bin/bash


# Loop until valid endpoint ID is provided
while true; do
  echo "Once created, paste the endpoint ID of the Multi-agent Supervisor:"
  read user_input
  endpoint_id=$user_input
  
  # Validate that endpoint_id starts with 'mas-'
  if [[ $endpoint_id =~ ^mas- ]]; then
    echo "Endpoint ID: $endpoint_id"
    break
  else
    echo "Error: Endpoint ID must start with 'mas-'. Please try again."
    echo ""
  fi
done

echo ''
echo "************************************************************"
echo "Updating apps/databricks.yml with the endpoint ID of the Multi-agent Supervisor"
echo "************************************************************"
echo ''

# Update the serving_endpoint_name default value in databricks.yml
# This finds the line after serving_endpoint_name: and replaces the default value
awk -v endpoint="$endpoint_id" '
/serving_endpoint_name:/ { in_block=1 }
in_block && /default:/ { 
  sub(/default:.*/, "default: " endpoint)
  in_block=0
}
{ print }
' ../databricks.yml > ../databricks.yml.tmp && mv ../databricks.yml.tmp ../databricks.yml

echo "Successfully updated serving_endpoint_name to: $endpoint_id"
echo "export DATABRICKS_SERVING_ENDPOINT='$endpoint_id'" >> ../../login_new_workspace.sh

