#! /usr/bin/env bash

BIN_DIR=${BIN_DIR:-$(cd "${0%/*}"&&pwd)}
source $BIN_DIR/util.sh
message Update NFT Feed

cd $BIN_DIR
ADDRESSES="./../../deployments/addresses_$(seth chain).json"

loadValuesFromFile $ADDRESSES

echo "NFT Registry Address: $1"
echo "Token id: $2"
echo "NFT Value: $3"
NFT_ID=$(seth call $NFT_FEED 'nftID(address,uint)' $1 $2)

seth send $NFT_FEED 'update(bytes32, uint)' $NFT_ID $3






