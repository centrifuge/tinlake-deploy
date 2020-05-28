#! /usr/bin/env bash

BIN_DIR=${BIN_DIR:-$(cd "${0%/*}"&&pwd)}
source $BIN_DIR/util.sh

cd $BIN_DIR
ADDRESSES="./../../deployments/addresses_$(seth chain).json"

CSV_FILE=$1
[ -z "$1" ] && CSV_FILE="./../../deployments/nft_values.csv"

loadValuesFromFile $ADDRESSES

LEN=$(xsv count $CSV_FILE)

for ((i=0; i < $LEN; i++))
do
   LINE=$(xsv slice -i $i $CSV_FILE)
   TOKEN_ID="$(echo "$LINE" | xsv select 'tokenID' |  tail -n1)"
   REGISTRY=$(echo "$LINE" | xsv select 'registry' |  tail -n1)
   VALUE=$(echo "$LINE" | xsv select 'value' |  tail -n1)
   RISK=$(echo "$LINE" | xsv select 'risk' |  tail -n1)

   ./update_nft_feed.sh --registry=$REGISTRY --tokenId=$TOKEN_ID --value=$VALUE --risk=$RISK

done


