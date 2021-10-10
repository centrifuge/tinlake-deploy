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

START_ETH_BALANCE=$(seth balance $ETH_FROM)

# deploy root contract
source ./root/deploy.sh

# deploy borrower contracts
source ./borrower/deploy.sh

# deploy lender contracts
source ./lender/deploy.sh

# finalize deployment
message Wire borrower and lender side

DEPLOY_USR="$(seth call $ROOT_CONTRACT 'deployUsr()(address)')"
if [ "$DEPLOY_USR" == "$ETH_FROM" ]; then
    if [ "$IS_MKR" == "true" ]; then
        seth send $ROOT_CONTRACT 'prepare(address,address,address,address,address[] memory,address)' $LENDER_DEPLOYER $BORROWER_DEPLOYER $ADAPTER_DEPLOYER $ORACLE "[$LEVEL1_ADMIN1,$LEVEL1_ADMIN2,$LEVEL1_ADMIN3,$LEVEL1_ADMIN4,$LEVEL1_ADMIN5,$AO_POOL_ADMIN] $LEVEL3_ADMIN1"
    else
        seth send $ROOT_CONTRACT 'prepare(address,address,address,address,address[] memory,address)' $LENDER_DEPLOYER $BORROWER_DEPLOYER $ADAPTER_DEPLOYER $ORACLE "[$LEVEL1_ADMIN1,$LEVEL1_ADMIN2,$LEVEL1_ADMIN3,$LEVEL1_ADMIN4,$LEVEL1_ADMIN5,$AO_POOL_ADMIN] $LEVEL3_ADMIN1"
    fi
fi

DEPLOYED="$(seth call $ROOT_CONTRACT 'deployed()(bool)')"
if [ "$DEPLOYED" == "false" ]; then
    seth send $ROOT_CONTRACT 'deploy()'
fi

END_ETH_BALANCE=$(seth balance $ETH_FROM)
ETH_SPENT="$((START_ETH_BALANCE-END_ETH_BALANCE))"

echo "Tinlake deployment $(seth chain)"
echo "Deployment file: $(realpath $DEPLOYMENT_FILE)"
echo "ETH spent: $(echo "$ETH_SPENT/10^18" | bc -l) ETH"

addValuesToFile $DEPLOYMENT_FILE <<EOF
{
    "MAIN_DEPLOYER"     :    "$MAIN_DEPLOYER",
    "COMMIT_HASH"       :    "$(git --git-dir ./../lib/tinlake/.git rev-parse HEAD )"
}
EOF

cat $DEPLOYMENT_FILE