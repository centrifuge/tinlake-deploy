#! /usr/bin/env bash

set -e

BIN_DIR=${BIN_DIR:-$(cd "${0%/*}"&&pwd)}
source $BIN_DIR/util/util.sh
export DAPP_JSON=$BIN_DIR/../lib/tinlake/out/dapp.sol.json
export DAPP_ROOT=$BIN_DIR/../lib/tinlake

cd $BIN_DIR

# todo it should be possible to define other path
DEPLOYMENT_FILE="./../deployments/addresses_$(seth chain).json"
ZERO_ADDRESS=0x0000000000000000000000000000000000000000

message Deploy borrower fabs

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

message Create borrower deployer

[[ -z "$BORROWER_DEPLOYER" ]] && BORROWER_DEPLOYER=$(dapp create "src/borrower/deployer.sol:BorrowerDeployer" $ROOT_CONTRACT $TITLE_FAB $SHELF_FAB $PILE_FAB $FEED_FAB $TINLAKE_CURRENCY '"Tinlake Loan Token"' '"TLNFT"' $DISCOUNT_RATE)
echo "BORROWER_DEPLOYER = $BORROWER_DEPLOYER"

addValuesToFile $DEPLOYMENT_FILE <<EOF
{
    "BORROWER_DEPLOYER"       :  "$BORROWER_DEPLOYER"
}
EOF

message Create borrower contracts

TITLE=$(seth call $BORROWER_DEPLOYER 'title()(address)')
if [ "$TITLE" == "$ZERO_ADDRESS" ]; then
    seth send $BORROWER_DEPLOYER 'deployTitle()'
    TITLE=$(seth call $BORROWER_DEPLOYER 'title()(address)')
fi
echo "TITLE = $TITLE"

PILE="$(seth call $BORROWER_DEPLOYER 'pile()(address)')"
if [ "$PILE" == "$ZERO_ADDRESS" ]; then
    seth send $BORROWER_DEPLOYER 'deployPile()'
    PILE="$(seth call $BORROWER_DEPLOYER 'pile()(address)')"
fi
echo "PILE = $PILE"

FEED="$(seth call $BORROWER_DEPLOYER 'feed()(address)')"
if [ "$FEED" == "$ZERO_ADDRESS" ]; then
    seth send $BORROWER_DEPLOYER 'deployFeed()'
    FEED=$(seth call $BORROWER_DEPLOYER 'feed()(address)')
fi
echo "FEED = $FEED"

SHELF="$(seth call $BORROWER_DEPLOYER 'shelf()(address)')"
if [ "$SHELF" == "$ZERO_ADDRESS" ]; then
    seth send $BORROWER_DEPLOYER 'deployShelf()'
    SHELF="$(seth call $BORROWER_DEPLOYER 'shelf()(address)')"
fi
echo "SHELF = $SHELF"

WIRED="$(seth call $BORROWER_DEPLOYER 'wired()(bool)')"
if [ "$WIRED" == "false" ]; then
    message "Wire borrower contracts"
    seth send $BORROWER_DEPLOYER 'deploy()'
fi

addValuesToFile $DEPLOYMENT_FILE <<EOF
{
    "TITLE"                   :  "$TITLE",
    "PILE"                    :  "$PILE",
    "SHELF"                   :  "$SHELF",
    "FEED"                    :  "$FEED"
}
EOF
