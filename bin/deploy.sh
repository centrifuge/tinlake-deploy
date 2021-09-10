#! /usr/bin/env bash

set -e
CONFIG_FILE=$1
[ -z "$1" ] && CONFIG_FILE="./bin/config_$(seth chain).json"
CONFIG_FILE=$(realpath "$CONFIG_FILE")

BIN_DIR=${BIN_DIR:-$(cd "${0%/*}"&&pwd)}

source $BIN_DIR/util/util.sh

loadValuesFromFile $CONFIG_FILE

cd $BIN_DIR

# check if all required env variables are defined
source $BIN_DIR/util/env-check.sh

read -p "Ready to deploy? [y/n] " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

# create deployment folder
mkdir -p $BIN_DIR/../deployments

[[ -z "$GOVERNANCE" ]] && GOVERNANCE="$ETH_FROM"

DEPLOYMENT_FILE="./../deployments/addresses_$(seth chain).json"
if [[ -z "$RESUME" ]]; then
    # empty existing deployment file
    truncate -s 0 $DEPLOYMENT_FILE
else
    loadValuesFromFile $DEPLOYMENT_FILE
fi

# deploy root contract
source ./root/deploy.sh

# deploy borrower contracts
source ./borrower/deploy.sh

# deploy lender contracts
source ./lender/deploy.sh

# finalize deployment
message Finalize Deployment

if [ "$IS_MKR" == "true" ]; then
    seth send $ROOT_CONTRACT 'prepare(address,address,address,address,address[] memory)' $LENDER_DEPLOYER $BORROWER_DEPLOYER $ADAPTER_DEPLOYER $ORACLE "[$POOL_ADMIN1,$POOL_ADMIN2,$POOL_ADMIN3,$POOL_ADMIN4,$POOL_ADMIN5,$AO_POOL_ADMIN]"
else
    seth send $ROOT_CONTRACT 'prepare(address,address,address,address,address[] memory)' $LENDER_DEPLOYER $BORROWER_DEPLOYER $ADAPTER_DEPLOYER $ORACLE "[$POOL_ADMIN1,$POOL_ADMIN2,$POOL_ADMIN3,$POOL_ADMIN4,$POOL_ADMIN5,$AO_POOL_ADMIN]"
fi

seth send $ROOT_CONTRACT 'deploy()'

success_msg "Tinlake Deployment $(seth chain)"
success_msg "Deployment File: $(realpath $DEPLOYMENT_FILE)"

addValuesToFile $DEPLOYMENT_FILE <<EOF
{
    "MAIN_DEPLOYER"     :    "$MAIN_DEPLOYER",
    "COMMIT_HASH"       :    "$(git --git-dir ./../lib/tinlake/.git rev-parse HEAD )"
}
EOF

cat $DEPLOYMENT_FILE

success_msg DONE