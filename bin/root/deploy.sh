#! /usr/bin/env bash

BIN_DIR=${BIN_DIR:-$(cd "${0%/*}"&&pwd)}
cd $BIN_DIR
CONTRACT_BIN=$BIN_DIR/../lib/tinlake/out

# todo it should be possible to define other path
DEPLOYMENT_FILE="./../deployments/addresses_$(seth chain).json"

DEPLOYMENT_NAME="Tinlake Deployment on $(seth chain)"

message Deploy Root Contract
export ROOT_CONTRACT=$(seth send --create $CONTRACT_BIN/TinlakeRoot.bin 'TinlakeRoot(address)' "$ETH_FROM")

touch $DEPLOYMENT_FILE
addValuesToFile $DEPLOYMENT_FILE <<EOF
{
    "DEPLOYMENT_NAME"   : "$DEPLOYMENT_NAME",
    "ROOT_CONTRACT"     : "$ROOT_CONTRACT",
    "TINLAKE_CURRENCY"  : "$TINLAKE_CURRENCY"
}
EOF
