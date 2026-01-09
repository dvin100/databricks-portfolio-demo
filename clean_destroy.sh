#------------------------------------------
# In a nutshell:
# ./deploy.sh will deploy the demo
#------------------------------------------

#------------------------------------------
# Deploy the workspace
#------------------------------------------
# Prior to running this script
# Login to ONEENV account and set the variable name to ONEENVAWS and set the environment variable DATABRICKS_CONFIG_PROFILE to ONEENVAWS
# databricks auth login -p ONEENVAWS
# export DATABRICKS_CONFIG_PROFILE="ONEENVAWS"

rm -rf dabs/.databricks
rm -rf dabs/structure/.databricks
rm -rf dabs/pipeline/.databricks
rm -rf dabs/dashboard/.databricks
rm -rf dabs/apps/.databricks
   
cd ./terraform/account
source ./login_account.sh

terraform destroy -auto-approve
