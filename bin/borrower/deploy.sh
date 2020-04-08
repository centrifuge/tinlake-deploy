#! /usr/bin/env bash

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
echo "TITLE_FAB: $TITLE_FAB"

SHELF_FAB=$(getFabContract $CONTRACT_BIN/ShelfFab.bin "SHELF_FAB")
echo "SHELF_FAB: $SHELF_FAB"

PILE_FAB=$(getFabContract $CONTRACT_BIN/PileFab.bin "PILE_FAB")
echo "PILE_FAB: $PILE_FAB"

COLLECTOR_FAB=$(getFabContract $CONTRACT_BIN/CollectorFab.bin "COLLECTOR_FAB")
echo "COLLECTOR_FAB: $COLLECTOR_FAB"

THRESHOLD_FAB=$(getFabContract $CONTRACT_BIN/ThresholdFab.bin "THRESHOLD_FAB")
echo "THRESHOLD_FAB: $THRESHOLD_FAB"

PRICEPOOL_FAB=$(getFabContract $CONTRACT_BIN/PricePoolFab.bin "PRICEPOOL_FAB")
echo "PRICEPOOL_FAB: $PRICEPOOL_FAB"

# default is Principal Ceiling Fab
CEILING_FAB=$(getFabContract $CONTRACT_BIN/PrincipalCeilingFab.bin "THRESHOLD_FAB")
echo "CEILING_FAB: $CEILING_FAB"

success_msg Borrower Fabs ready

TITLE_NAME="Tinlake Loan Token"
TITLE_SYMBOL="TLNT"

message Create Borrower Deployer

export BORROWER_DEPLOYER=$(seth send --create $CONTRACT_BIN/BorrowerDeployer.bin 'BorrowerDeployer(address,address,address,address,address,address,address,address,address,string memory,string memory)' $ROOT_CONTRACT $TITLE_FAB $SHELF_FAB $PILE_FAB $CEILING_FAB $COLLECTOR_FAB $THRESHOLD_FAB $PRICEPOOL_FAB $TINLAKE_CURRENCY "$TITLE_NAME" "$TITLE_SYMBOL")

message "Deploy Title contract"
seth send $BORROWER_DEPLOYER 'deployTitle()'
message "Deploy Pile contract"
seth send $BORROWER_DEPLOYER 'deployPile()'
message "Deploy Ceiling contract"
seth send $BORROWER_DEPLOYER 'deployCeiling()'
message "Deploy Shelf contract"
seth send $BORROWER_DEPLOYER 'deployShelf()'
seth send $BORROWER_DEPLOYER 'deployThreshold()'
seth send $BORROWER_DEPLOYER 'deployCollector()'
seth send $BORROWER_DEPLOYER 'deployPricePool()'

seth send $BORROWER_DEPLOYER 'deploy()'

success_msg Borrower Contracts deployed

touch $DEPLOYMENT_FILE
addValuesToFile $DEPLOYMENT_FILE <<EOF
{
    "BORROWER_DEPLOYER"       :  "$BORROWER_DEPLOYER",
    "TITLE_FAB"      :  "$TITLE_FAB",
    "SHELF_FAB"      :  "$SHELF_FAB",
    "PILE_FAB"       :  "$PILE_FAB",
    "COLLECTOR_FAB"  :  "$COLLECTOR_FAB",
    "THRESHOLD_FAB"  :  "$THRESHOLD_FAB",
    "PRICEPOOL_FAB"  :  "$PRICEPOOL_FAB",
    "CEILING_FAB"    :  "$CEILING_FAB",
    "TITLE"          :  "$(seth call $BORROWER_DEPLOYER 'title()(address)')",
    "PILE"           :  "$(seth call $BORROWER_DEPLOYER 'pile()(address)')",
    "SHELF"          :  "$(seth call $BORROWER_DEPLOYER 'shelf()(address)')",
    "CEILING"        :  "$(seth call $BORROWER_DEPLOYER 'ceiling()(address)')",
    "COLLECTOR"      :  "$(seth call $BORROWER_DEPLOYER 'collector()(address)')",
    "THRESHOLD"      :  "$(seth call $BORROWER_DEPLOYER 'threshold()(address)')",
    "PRICE_POOL"     :  "$(seth call $BORROWER_DEPLOYER 'pricePool()(address)')"
}
EOF
