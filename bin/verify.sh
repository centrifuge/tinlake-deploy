
#! /usr/bin/env bash

set -e

BIN_DIR=${BIN_DIR:-$(cd "${0%/*}"&&pwd)}
cd $BIN_DIR
source $BIN_DIR/util/util.sh

export DAPP_JSON=$BIN_DIR/../lib/tinlake/out/dapp.sol.json
export DAPP_ROOT=$BIN_DIR/../lib/tinlake

message verify Tinlake contracts

ADDRESSES_FILE="./../deployments/addresses_$(seth chain).json"
CONFIG_FILE="./config_$(seth chain).json"


loadValuesFromFile $CONFIG_FILE
loadValuesFromFile $ADDRESSES_FILE

[[ -z "$GOVERNANCE" ]] && GOVERNANCE="$ETH_FROM"

message verify root $ROOT_CONTRACT
dapp verify-contract --async 'src/root.sol:TinlakeRoot' $ROOT_CONTRACT "$ETH_FROM" "$GOVERNANCE"


message verify borrower contracts
message verify borrower deployer $BORROWER_DEPLOYER
dapp verify-contract --async "src/borrower/deployer.sol:BorrowerDeployer" $BORROWER_DEPLOYER $ROOT_CONTRACT $TITLE_FAB $SHELF_FAB $PILE_FAB $COLLECTOR_FAB $FEED_FAB $TINLAKE_CURRENCY '"Tinlake Loan Token"' '"TLNFT"' $DISCOUNT_RATE

message verify title $TITLE 
dapp verify-contract --async 'lib/tinlake-title/src/title.sol:Title' $TITLE '"Tinlake Loan Token"' '"TLNFT"'

message verify pile $PILE
dapp verify-contract --async 'src/borrower/pile.sol:Pile' $PILE

message verify feed $FEED
dapp verify-contract --async 'src/borrower/feed/navfeed.sol:NAVFeed' $FEED

message verify shelf $SHELF
dapp verify-contract --async 'src/borrower/shelf.sol:Shelf' $SHELF $TINLAKE_CURRENCY $TITLE $PILE $FEED

message verify collector $COLLECTOR
dapp verify-contract --async 'src/borrower/collect/collector.sol:Collector' $COLLECTOR $SHELF $PILE $FEED

message verify lender contracts
message verify lender deployer $LENDER_DEPLOYER
dapp verify-contract --async "src/lender/deployer.sol:LenderDeployer" $LENDER_DEPLOYER $ROOT_CONTRACT $TINLAKE_CURRENCY $TRANCHE_FAB $MEMBERLIST_FAB $RESTRICTED_TOKEN_FAB $RESERVE_FAB $ASSESSOR_FAB $COORDINATOR_FAB $OPERATOR_FAB $POOL_ADMIN_FAB $MEMBER_ADMIN $ADAPTER_DEPLOYER

message verify junior tranche contracts
dapp verify-contract --async 'src/lender/token/restricted.sol:RestrictedToken' $JUNIOR_TOKEN \"$JUNIOR_TOKEN_SYMBOL\" \"$JUNIOR_TOKEN_NAME\"
dapp verify-contract --async 'src/lender/tranche.sol:Tranche' $JUNIOR_TRANCHE $TINLAKE_CURRENCY $JUNIOR_TOKEN
dapp verify-contract --async 'src/lender/token/memberlist.sol:Memberlist' $JUNIOR_MEMBERLIST
dapp verify-contract --async 'src/lender/operator.sol:Operator' $JUNIOR_OPERATOR $JUNIOR_TRANCHE

message verify senior tranche contracts
dapp verify-contract --async 'src/lender/token/restricted.sol:RestrictedToken' $SENIOR_TOKEN \"$SENIOR_TOKEN_SYMBOL\" \"$SENIOR_TOKEN_NAME\"
dapp verify-contract --async 'src/lender/tranche.sol:Tranche' $SENIOR_TRANCHE $TINLAKE_CURRENCY $SENIOR_TOKEN
dapp verify-contract --async 'src/lender/token/memberlist.sol:Memberlist' $SENIOR_MEMBERLIST
dapp verify-contract --async 'src/lender/operator.sol:Operator' $SENIOR_OPERATOR $SENIOR_TRANCHE

message verify reserve $RESERVE 
dapp verify-contract --async 'src/lender/reserve.sol:Reserve' $RESERVE $TINLAKE_CURRENCY
message verify assessor $ASSESSOR
dapp verify-contract --async 'src/lender/assessor.sol:Assessor' $ASSESSOR
message verify pool admin $POOL_ADMIN
dapp verify-contract --async 'src/lender/admin/pool.sol:PoolAdmin' $POOL_ADMIN
message verify epoch coordinator $COORDINATOR
dapp verify-contract --async 'src/lender/coordinator.sol:EpochCoordinator' $COORDINATOR $CHALLENGE_TIME

if [ "$IS_MKR" == "true" ]; then
  message verify adapter deployer $ADAPTER_DEPLOYER
  dapp verify-contract --async "src/lender/adapters/deployer.sol:AdapterDeployer" $ADAPTER_DEPLOYER $ROOT_CONTRACT $CLERK_FAB $MKR_MGR_FAB

  message verify clerk $CLERK
  dapp verify-contract --async 'src/lender/adapters/mkr/clerk.sol:Clerk' $CLERK

  message TODO: verify manager manually
fi