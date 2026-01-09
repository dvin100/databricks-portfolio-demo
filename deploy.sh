#------------------------------------------
# In a nutshell:
# ./deploy.sh will deploy the demo
#------------------------------------------

#------------------------------------------
# Deploy the workspace
#------------------------------------------
# Prior to running this script
# Login to ONEENV account and set the profile to ONEENVAWS.
# Set the environment variable DATABRICKS_CONFIG_PROFILE to ONEENVAWS
# databricks auth login -p ONEENVAWS
# export DATABRICKS_CONFIG_PROFILE="ONEENVAWS"

HOME_DEPLOYDIR=$(pwd)
echo "HOME_DEPLOYDIR: $HOME_DEPLOYDIR"

echo ''
echo "************************************************************"
echo "Creating the workspace"
echo "************************************************************"
echo ''

cd $HOME_DEPLOYDIR/terraform/account
source ./login_account.sh

terraform init
terraform plan
terraform apply -auto-approve

echo ''
echo "************************************************************"
echo "Creating the login_new_workspace.sh file"
echo "************************************************************"
echo ''
terraform output -raw login_new_workspace > $HOME_DEPLOYDIR/dabs/login_new_workspace.sh
echo "\n" >> $HOME_DEPLOYDIR/dabs/login_new_workspace.sh
terraform output -raw set_env_variable_config_profile >> $HOME_DEPLOYDIR/dabs/login_new_workspace.sh
echo "\n" >> $HOME_DEPLOYDIR/dabs/login_new_workspace.sh
terraform output -raw set_env_variable_host >> $HOME_DEPLOYDIR/dabs/login_new_workspace.sh
echo "\n" >> $HOME_DEPLOYDIR/dabs/login_new_workspace.sh

chmod 700 $HOME_DEPLOYDIR/dabs/login_new_workspace.sh

echo ''
echo "************************************************************"
echo "Login to the new workspace... might require a browser login"
echo "************************************************************"
echo ''
cd $HOME_DEPLOYDIR/dabs/
source ./login_new_workspace.sh
cd $HOME_DEPLOYDIR/dabs/lakebase/
./setup.sh
exit 0;
echo ''
echo "************************************************************"
echo "Creating the SQL warehouse"
echo "************************************************************"
echo ''
cd $HOME_DEPLOYDIR/dabs/structure/
./scripts/sql_warehouse.sh

cd ../
echo ''
echo "************************************************************"
echo "Copying the databricks.yml file to the DABs directories"
echo "************************************************************"
echo ''

cp -f $HOME_DEPLOYDIR/dabs/databricks.yml $HOME_DEPLOYDIR/dabs/structure/
# Change the bundle name in the copied file
sed -i '' 's/BUNDLE_NAME/structure/' $HOME_DEPLOYDIR/dabs/structure/databricks.yml

cp -f $HOME_DEPLOYDIR/dabs/databricks.yml $HOME_DEPLOYDIR/dabs/pipeline/
# Change the bundle name in the copied file
sed -i '' 's/BUNDLE_NAME/pipeline/' $HOME_DEPLOYDIR/dabs/pipeline/databricks.yml

cp -f $HOME_DEPLOYDIR/dabs/databricks.yml $HOME_DEPLOYDIR/dabs/dashboard/
# Change the bundle name in the copied file
sed -i '' 's/BUNDLE_NAME/dashboard/' $HOME_DEPLOYDIR/dabs/dashboard/databricks.yml

cp -f $HOME_DEPLOYDIR/dabs/databricks.yml $HOME_DEPLOYDIR/dabs/apps/
# Change the bundle name in the copied file
sed -i '' 's/BUNDLE_NAME/apps/' $HOME_DEPLOYDIR/dabs/apps/databricks.yml

echo ''
echo "************************************************************"
echo "Validating the creation of the marketplace catalog called news"
echo "************************************************************"
echo ''
cd $HOME_DEPLOYDIR/dabs/structure/
./scripts/marketplace.sh  

echo ''
echo "!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-"
echo "ACTION REQUIRED: manually create the catalog with the same name as the one have set in the " 
echo "databricks.yml file. (Currently a bug)"
echo "!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-"
echo ''
echo "Confirm action completion by hitting ENTER to continue"
read user_input

echo ''
echo "!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-"
echo "ACTION REQUIRED: in the UI, set the workspace default catalog to the catalog you have just created"
echo "!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-"
echo ''
echo "Confirm action completion by hitting ENTER to continue"
read user_input

echo ''
echo "************************************************************"
echo "Deploying the STRUCTURE bundle"
echo "************************************************************"
echo ''
databricks bundle deploy --target dev


echo ''
echo "************************************************************"
echo "Running the data job to create the required objects in Unity Catalog"
echo "************************************************************"
echo ''
databricks bundle run lakeflow_job --target dev

echo ''
echo "************************************************************"
echo "Copying the PDFs and CSVs to volume"
echo "************************************************************"
echo ''
databricks fs cp $HOME_DEPLOYDIR/dabs/structure/fixtures dbfs:/Volumes/demo/portfolio/artifacts/ -r

echo ''
echo "************************************************************"
echo "Deploying the PIPELINE bundle"
echo "************************************************************"
echo ''
cd $HOME_DEPLOYDIR/dabs/pipeline/
databricks bundle deploy --target dev

echo ''
echo "************************************************************"
echo "Running the data pipeline"
echo "************************************************************"
echo ''
databricks bundle run lakeflow_pipeline --target dev

echo ''
echo "************************************************************"
echo "Creating the Genie space"
echo "************************************************************"
echo ''
cd $HOME_DEPLOYDIR/dabs/dashboard/scripts/
./genie.sh

echo ''
echo "************************************************************"
echo "Deploying the DASHBOARD bundle"
echo "************************************************************"
echo ''
cd $HOME_DEPLOYDIR/dabs/dashboard/
databricks bundle deploy --target dev

echo ''
echo "************************************************************"
echo "Replacing the Dashboard embedding URLs in the apps"
echo "************************************************************"
echo ''
cd $HOME_DEPLOYDIR/dabs/dashboard/scripts/
./dash_embedding_apps.sh

echo ''
echo "!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-"
echo "ACTION REQUIRED: Manually grant access to the Genie space to all users"
echo "!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-"
echo ''
echo "Confirm action completion by hitting ENTER to continue"
read user_input

echo ''
echo "!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-"
echo "ACTION REQUIRED: Activate the preview feature 'Mosaic AI Agent Bricks Preview' in the UI"
echo "!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-"
echo ''
echo "Confirm action completion by hitting ENTER to continue"
read user_input

echo ''
echo "!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-"
echo "ACTION REQUIRED: Activate the preview feature 'External Tool Calling for Agents' in the UI and press enter to continue"
echo "!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-"
echo ''
echo "Confirm action completion by hitting ENTER to continue"
read user_input

echo ''
echo "!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-"
echo "ACTION REQUIRED: Activate both preview features 'On-Behalf-Of-User Authorization' in the UI and press enter to continue"
echo "!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-"
echo ''
echo "Confirm action completion by hitting ENTER to continue"
read user_input

echo ''
echo "!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-"
echo "ACTION REQUIRED: Activate the preview features 'Managed MCP Servers' in the UI and press enter to continue"
echo "!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-"
echo ''
echo "Confirm action completion by hitting ENTER to continue"
read user_input


echo ''
echo "!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-"
echo "ACTION REQUIRED: Grant access to allow dashboard embedding (Settings/security/embed dashboard) and press enter to continue"
echo "!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-"
echo ''
echo "Confirm action completion by hitting ENTER to continue"
read user_input

echo ''
echo "!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-"
echo "ACTION REQUIRED: Create the Knowledge Assistant Agent in the UI and press enter to continue"
echo "!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-"
echo ''
echo "Confirm action completion by hitting ENTER to continue"
read user_input

echo ''
echo "!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-"
echo "ACTION REQUIRED: Create the Multi-agent Supervisor"
echo "!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-"
echo ''
cd $HOME_DEPLOYDIR/dabs/apps/scripts/
./agent.sh

echo ''
echo "************************************************************"
echo "Deploying the apps bundle"
echo "************************************************************"
echo ''
cd $HOME_DEPLOYDIR/dabs/apps/
databricks bundle deploy --target dev

echo ''
echo "************************************************************"
echo "Running the apps"
echo "************************************************************"
echo ''
databricks bundle run databricks_portfolio_apps

echo ''
echo "!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-"
echo "ACTION REQUIRED: Manually assign the app Service Principal the right to use" 
echo "the Multi-agent Supervisor and the Knowledge Assistant Agent endpoints"
echo "!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-"
echo ''
echo "Confirm action completion by hitting ENTER to continue"
read user_input

echo ''
echo "!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-"
echo "ACTION REQUIRED: Copy the lakebase variables in the file dabs/lakebase/lakebase_variable.sh "
echo "!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-"
echo ''
echo "Confirm action completion by hitting ENTER to continue"
read user_input

echo ''
echo "************************************************************"
echo "Creating the lakebase_demo database and userstable"
echo "************************************************************"
echo ''
cd $HOME_DEPLOYDIR/dabs/lakebase/
./setup.sh

echo ''
echo "************************************************************"
echo "Deployment completed"
echo "************************************************************"
echo ''

