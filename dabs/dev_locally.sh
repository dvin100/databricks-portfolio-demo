echo "************************************************************"
echo "Run this script from the dabs/apps/src directory"
echo "../scripts/local_dev.sh"
echo "Running the apps locally"
echo "http://localhost:3000/"
echo "************************************************************"

source ./login_new_workspace.sh
source ./lakebase/set_lakebase_variable.sh
cd apps/src 

# Open browser after a short delay to allow server to start
(sleep 3 && open http://localhost:3000) &

npm run dev