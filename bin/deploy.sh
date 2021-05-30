#! /usr/bin/env bash

set -e
CONFIG_FILE=$1
[ -z "$1" ] && CONFIG_FILE="./bin/config_$(seth chain).json"
CONFIG_FILE=$(realpath "$CONFIG_FILE")

BIN_DIR=${BIN_DIR:-$(cd "${0%/*}"&&pwd)}

source $BIN_DIR/util/util.sh
message Start Tinlake deployment

loadValuesFromFile $CONFIG_FILE

cd $BIN_DIR

# check if all required env variables are defined
source $BIN_DIR/util/env-check.sh

success_msg "Correct Config File"

message Tinlake Deployment Config

cat $CONFIG_FILE

# create deployment folder
mkdir -p $BIN_DIR/../deployments

[[ -z "$GOVERNANCE" ]] && GOVERNANCE="$ETH_FROM"

# deploy root contract
source ./root/deploy.sh

# deploy borrower contracts
source ./borrower/deploy.sh

# deploy lender contracts
source ./lender/deploy.sh

# finalize deployment
message Finalize Deployment

seth send $ROOT_CONTRACT 'prepare(address,address)' $LENDER_DEPLOYER $BORROWER_DEPLOYER
seth send $ROOT_CONTRACT 'deploy(address,address,address,address,address,address,address)' $ORACLE $POOL_ADMIN1 $POOL_ADMIN2 $POOL_ADMIN3 $POOL_ADMIN4 $POOL_ADMIN5 $AO_POOL_ADMIN

success_msg "Tinlake Deployment $(seth chain)"
success_msg "Deployment File: $(realpath $DEPLOYMENT_FILE)"

#touch $DEPLOYMENT_FILE
addValuesToFile $DEPLOYMENT_FILE <<EOF
{
    "MAIN_DEPLOYER"     :    "$MAIN_DEPLOYER",
    "COMMIT_HASH"       :    "$(git --git-dir ./../lib/tinlake/.git rev-parse HEAD )"
}
EOF

cat $DEPLOYMENT_FILE

success_msg DONE
