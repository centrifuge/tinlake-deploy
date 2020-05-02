#! /usr/bin/env bash



CACHE_DIRECTORY="/etc/cache"

# Loop through arguments and process them
for arg in "$@"
do
    case $arg in
        -r=*|--registry=*)
        NFT_REGISTRY="${arg#*=}"
        shift # Remove --cache= from processing
        ;;
        -t=*|--tokenId=*)
        TOKEN_ID="${arg#*=}"
        shift # Remove --cache= from processing
        ;;
        -v=*|--value=*)
        NFT_VALUE="${arg#*=}"
        shift # Remove --cache= from processing
        ;;
    esac
done

BIN_DIR=${BIN_DIR:-$(cd "${0%/*}"&&pwd)}
source $BIN_DIR/util.sh
message Update NFT Feed

cd $BIN_DIR
ADDRESSES="./../../deployments/addresses_$(seth chain).json"

loadValuesFromFile $ADDRESSES

echo "NFT Registry Address: $NFT_REGISTRY"
echo "Token id: $TOKEN_ID"
echo "NFT Value: $NFT_VALUE"
NFT_ID=$(seth call $NFT_FEED 'nftID(address,uint)' $NFT_REGISTRY $TOKEN_ID)

seth send $NFT_FEED 'update(bytes32, uint)' $NFT_ID $NFT_VALUE






