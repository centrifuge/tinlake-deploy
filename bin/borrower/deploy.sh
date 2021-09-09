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

TITLE_FAB=$(getFabContract src/borrower/fabs/title.sol TitleFab "TITLE_FAB")
echo "TITLE_FAB = $TITLE_FAB"

SHELF_FAB=$(getFabContract src/borrower/fabs/shelf.sol ShelfFab "SHELF_FAB")
echo "SHELF_FAB = $SHELF_FAB"

PILE_FAB=$(getFabContract src/borrower/fabs/pile.sol PileFab "PILE_FAB")
echo "PILE_FAB = $PILE_FAB"

if [ "$NAV_IMPLEMENTATION" == "creditline" ]; then
    FEED_FAB=$(getFabContract src/borrower/fabs/navfeed.creditline.sol CreditlineNAVFeedFab "FEED_FAB")
else
    FEED_FAB=$(getFabContract src/borrower/fabs/navfeed.principal.sol PrincipalNAVFeedFab "FEED_FAB")
fi
echo "FEED_FAB = $FEED_FAB"

success_msg Borrower Fabs ready

message Create Borrower Deployer

[[ -z "$BORROWER_DEPLOYER" ]] && BORROWER_DEPLOYER=$(dapp create "src/borrower/deployer.sol:BorrowerDeployer" $ROOT_CONTRACT $TITLE_FAB $SHELF_FAB $PILE_FAB $FEED_FAB $TINLAKE_CURRENCY '"Tinlake Loan Token"' '"TLNFT"' $DISCOUNT_RATE)
echo "BORROWER_DEPLOYER = $BORROWER_DEPLOYER"

message Create Borrower Contracts

TITLE=$(seth call $BORROWER_DEPLOYER 'title()(address)')
echo "TITLE = $TITLE"
if [ -z "$TITLE" ] then
    seth send $BORROWER_DEPLOYER 'deployTitle()'
    TITLE=$(seth call $BORROWER_DEPLOYER 'title()(address)')
fi
echo "TITLE = $TITLE"

PILE="$(seth call $BORROWER_DEPLOYER 'pile()(address)')"
if [ -z "$TITLE" ] then
    seth send $BORROWER_DEPLOYER 'deployPile()'
    PILE="$(seth call $BORROWER_DEPLOYER 'pile()(address)')"
fi
echo "PILE = $PILE"

if [ "$NAV_IMPLEMENTATION" == "creditline" ]; then
    seth send $BORROWER_DEPLOYER 'deployFeed(bool)' true
else
    seth send $BORROWER_DEPLOYER 'deployFeed(bool)' false
fi
FEED=$(seth call $BORROWER_DEPLOYER 'feed()(address)')
echo "FEED = $FEED"

seth send $BORROWER_DEPLOYER 'deployShelf()'
SHELF="$(seth call $BORROWER_DEPLOYER 'shelf()(address)')"
echo "SHELF = $SHELF"

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
    "FEED_FAB"                :  "$FEED_FAB",
    "TITLE"                   :  "$TITLE",
    "PILE"                    :  "$PILE",
    "SHELF"                   :  "$SHELF",
    "FEED"                    :  "$FEED"
}
EOF
