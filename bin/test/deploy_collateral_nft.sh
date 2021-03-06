#! /usr/bin/env bash

BIN_DIR=${BIN_DIR:-$(cd "${0%/*}"&&pwd)}
cd $BIN_DIR
CONTRACT_BIN=$BIN_DIR/../../lib/tinlake/out

source $BIN_DIR/../util/util.sh

# set SETH enviroment variable
source ./local_env.sh

export COLLATERAL_NFT=$(seth send --create $CONTRACT_BIN/Title.bin 'Title(string memory, string memory)' '"Test Collateral NFT"' '"TNFT"')

message Collateral NFT Address: $COLLATERAL_NFT

DEPLOYMENT_FILE=$BIN_DIR/../../deployments/addresses_$(seth chain).json
touch $DEPLOYMENT_FILE
addValuesToFile $DEPLOYMENT_FILE <<EOF
{
    "COLLATERAL_NFT" :"$COLLATERAL_NFT"
}
EOF
