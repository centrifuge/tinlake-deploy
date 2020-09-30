#! /usr/bin/env bash

set -e

BIN_DIR=${BIN_DIR:-$(cd "${0%/*}"&&pwd)}
source $BIN_DIR/util/util.sh
export DAPP_JSON=$BIN_DIR/../lib/tinlake/out/dapp.sol.json
export DAPP_ROOT=$BIN_DIR/../lib/tinlake

cd $BIN_DIR

message Deploy Borrower

# todo it should be possible to define other path
DEPLOYMENT_FILE="./../deployments/addresses_$(seth chain).json"
ZERO_ADDRESS=0x0000000000000000000000000000000000000000

message Fetch Fab Addresses or Deploy

TITLE_FAB=$(getFabContract src/borrower/fabs/title.sol:TitleFab "TITLE_FAB")
message "TITLE_FAB: $TITLE_FAB"

SHELF_FAB=$(getFabContract src/borrower/fabs/shelf.sol:ShelfFab "SHELF_FAB")
message "SHELF_FAB: $SHELF_FAB"

PILE_FAB=$(getFabContract src/borrower/fabs/pile.sol:PileFab "PILE_FAB")
message "PILE_FAB: $PILE_FAB"

COLLECTOR_FAB=$(getFabContract src/borrower/fabs/collector.sol:CollectorFab "COLLECTOR_FAB")
message "COLLECTOR_FAB: $COLLECTOR_FAB"

# deploy nft feed or ceiling and threshold
FEED_FAB=$(getFabContract 'src/borrower/fabs/navfeed.sol:NAVFeedFab' "FEED_FAB")
message "FEED_FAB: $FEED_FAB"

success_msg Borrower Fabs ready

message Create Borrower Deployer

export BORROWER_DEPLOYER=$(dapp create --verify "src/borrower/deployer.sol:BorrowerDeployer" $ROOT_CONTRACT $TITLE_FAB $SHELF_FAB $PILE_FAB $COLLECTOR_FAB $FEED_FAB $TINLAKE_CURRENCY '"Tinlake Loan Token"' '"TLNFT"' $DISCOUNT_RATE)

message "deploy title contract"

seth send $BORROWER_DEPLOYER 'deployTitle()'
export TITLE=$(seth call $BORROWER_DEPLOYER 'title()(address)')
dapp verify-contract 'lib/tinlake-title/src/title.sol:Title' $TITLE '"Tinlake Loan Token"' '"TLNFT"'

message "deploy pile contract"
seth send $BORROWER_DEPLOYER 'deployPile()'
export PILE="$(seth call $BORROWER_DEPLOYER 'pile()(address)')"
dapp verify-contract 'src/borrower/pile.sol:Pile' $PILE

message "deploy nftFeed contract"
seth send $BORROWER_DEPLOYER 'deployFeed()'
export FEED=$(seth call $BORROWER_DEPLOYER 'feed()(address)')
dapp verify-contract "src/borrower/feed/navfeed.sol:NAVFeed" $FEED

message "deploy shelf contract"
seth send $BORROWER_DEPLOYER 'deployShelf()'
export SHELF="$(seth call $BORROWER_DEPLOYER 'shelf()(address)')"
dapp verify-contract 'src/borrower/shelf.sol:Shelf' $SHELF $TINLAKE_CURRENCY $TITLE $PILE $FEED

message "deploy collector contract"
seth send $BORROWER_DEPLOYER 'deployCollector()'
export COLLECTOR=$(seth call $BORROWER_DEPLOYER 'collector()(address)')
dapp verify-contract 'src/borrower/collect/collector.sol:Collector' $COLLECTOR $SHELF $PILE $FEED

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
    "TITLE"                   :  "$TITLE",
    "PILE"                    :  "$PILE",
    "SHELF"                   :  "$SHELF",
    "COLLECTOR"               :  "$COLLECTOR",
    "FEED"                    :  "$FEED"
}
EOF
