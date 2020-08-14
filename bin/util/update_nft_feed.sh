#! /usr/bin/env bash

# fetch arguments
for arg in "$@"
do
    case $arg in
        -r=*|--registry=*)
        NFT_REGISTRY="${arg#*=}"
        shift
        ;;
        -t=*|--tokenId=*)
        TOKEN_ID="${arg#*=}"
        shift
        ;;
        -v=*|--value=*)
        NFT_VALUE="${arg#*=}"
        shift
        ;;
        -r=*|--risk=*)
        RISK="${arg#*=}"
        shift
        ;;
    esac
done

BIN_DIR=${BIN_DIR:-$(cd "${0%/*}"&&pwd)}
source $BIN_DIR/util.sh

cd $BIN_DIR
ADDRESSES="./../../deployments/addresses_$(seth chain).json"

loadValuesFromFile $ADDRESSES
message Input Data
echo "NFT Registry Address: $NFT_REGISTRY"
echo "Token id: $TOKEN_ID"
echo "NFT Value: $NFT_VALUE"
echo "Risk Group: $RISK"

NFT_ID=$(seth call $NFT_FEED 'nftID(address,uint)' $NFT_REGISTRY $TOKEN_ID)
echo $NFT_ID
if [ ! -z "$RISK" ]
then
     message Update Feed with Value and Risk
     seth send $NFT_FEED 'update(bytes32, uint, uint)' $NFT_ID $NFT_VALUE $RISK
else
    message Update Feed with Value
     seth send $NFT_FEED 'update(bytes32, uint)' $NFT_ID $NFT_VALUE
fi

message Call Contract to verify
echo "NFT Value: $(seth call $NFT_FEED 'nftValues(bytes32)(uint)' $NFT_ID)"
echo "Risk Group: $(seth call $NFT_FEED 'risk(bytes32)(uint)' $NFT_ID)"






