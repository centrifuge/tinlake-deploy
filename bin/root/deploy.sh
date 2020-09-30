#! /usr/bin/env bash

set -e

BIN_DIR=${BIN_DIR:-$(cd "${0%/*}"&&pwd)}
source $BIN_DIR/util/util.sh
export DAPP_JSON=$BIN_DIR/../lib/tinlake/out/dapp.sol.json
export DAPP_ROOT=$BIN_DIR/../lib/tinlake

cd $BIN_DIR

# todo it should be possible to define other path
DEPLOYMENT_FILE="./../deployments/addresses_$(seth chain).json"

DEPLOYMENT_NAME="Tinlake Deployment on $(seth chain)"

message Deploy Root Contract

export ROOT_CONTRACT=$(dapp create --verify src/root.sol:TinlakeRoot "$ETH_FROM")

touch $DEPLOYMENT_FILE
addValuesToFile $DEPLOYMENT_FILE <<EOF
{
    "DEPLOYMENT_NAME"   : "$DEPLOYMENT_NAME",
    "ROOT_CONTRACT"     : "$ROOT_CONTRACT",
    "TINLAKE_CURRENCY"  : "$TINLAKE_CURRENCY"
}
EOF
