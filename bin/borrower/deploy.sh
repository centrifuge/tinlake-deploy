#! /usr/bin/env bash

set -e

BIN_DIR=${BIN_DIR:-$(cd "${0%/*}"&&pwd)}
source $BIN_DIR/util/util.sh
CONTRACT_BIN=$BIN_DIR/../lib/tinlake/out

cd $BIN_DIR

message Deploy Borrower

# todo it should be possible to define other path
DEPLOYMENT_FILE="./../deployments/addresses_$(seth chain).json"
ZERO_ADDRESS=0x0000000000000000000000000000000000000000

message Fetch Fab Addresses or Deploy

TITLE_FAB=$(getFabContract $CONTRACT_BIN/TitleFab.bin "TITLE_FAB")
message "TITLE_FAB: $TITLE_FAB"

SHELF_FAB=$(getFabContract $CONTRACT_BIN/ShelfFab.bin "SHELF_FAB")
message "SHELF_FAB: $SHELF_FAB"

PILE_FAB=$(getFabContract $CONTRACT_BIN/PileFab.bin "PILE_FAB")
message "PILE_FAB: $PILE_FAB"

COLLECTOR_FAB=$(getFabContract $CONTRACT_BIN/CollectorFab.bin "COLLECTOR_FAB")
message "COLLECTOR_FAB: $COLLECTOR_FAB"



# deploy nft feed or ceiling and threshold
if [ "$FEED"  ==  "nav" ]; then
    FEED_FAB=$(getFabContract $CONTRACT_BIN/NAVFeedFab.bin "FEED_FAB")
else
    FEED_FAB=$(getFabContract $CONTRACT_BIN/NFTFeedFab.bin "FEED_FAB")
fi
message "FEED_FAB: $FEED_FAB"


success_msg Borrower Fabs ready

TITLE_NAME="Tinlake Loan Token"
TITLE_SYMBOL="TLNT"

message Create Borrower Deployer

export BORROWER_DEPLOYER=$(seth send --create $CONTRACT_BIN/BorrowerDeployer.bin 'BorrowerDeployer(address,address,address,address,address,address,address,string memory,string memory)' $ROOT_CONTRACT $TITLE_FAB $SHELF_FAB $PILE_FAB $COLLECTOR_FAB $FEED_FAB $TINLAKE_CURRENCY "$TITLE_NAME" "$TITLE_SYMBOL")

message "deploy title contract"
seth send $BORROWER_DEPLOYER 'deployTitle()'
message "deploy pile contract"
seth send $BORROWER_DEPLOYER 'deployPile()'

message "deploy nftFeed contract"
seth send $BORROWER_DEPLOYER 'deployFeed()'

message "deploy shelf contract"
seth send $BORROWER_DEPLOYER 'deployShelf()'
message "deploy collector contract"
seth send $BORROWER_DEPLOYER 'deployCollector()'
message "finalize borrower contracts"
seth send $BORROWER_DEPLOYER 'deploy()'

success_msg Borrower Contracts deployed

touch $DEPLOYMENT_FILE
addValuesToFile $DEPLOYMENT_FILE <<EOF
{
    "BORROWER_DEPLOYER"       :  "$BORROWER_DEPLOYER",
    "TITLE_FAB"               :  "$TITLE_FAB",
    "SHELF_FAB"               :  "$SHELF_FAB",
    "PILE_FAB"                :  "$PILE_FAB",
    "COLLECTOR_FAB"           :  "$COLLECTOR_FAB",
    "FEED_FAB"                :  "$FEED_FAB",
    "TITLE"                   :  "$(seth call $BORROWER_DEPLOYER 'title()(address)')",
    "PILE"                    :  "$(seth call $BORROWER_DEPLOYER 'pile()(address)')",
    "SHELF"                   :  "$(seth call $BORROWER_DEPLOYER 'shelf()(address)')",
    "COLLECTOR"               :  "$(seth call $BORROWER_DEPLOYER 'collector()(address)')",
    "FEED"                    :  "$(seth call $BORROWER_DEPLOYER 'feed()(address)')"
}
EOF
