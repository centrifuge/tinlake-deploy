
#! /usr/bin/env bash

set -e

BIN_DIR=${BIN_DIR:-$(cd "${0%/*}"&&pwd)}
cd $BIN_DIR
source $BIN_DIR/util/util.sh

export DAPP_JSON=$BIN_DIR/../lib/tinlake/out/dapp.sol.json
export DAPP_ROOT=$BIN_DIR/../lib/tinlake

message Verify Tinlake contracts

ADDRESSES_FILE="./../deployments/addresses_$(seth chain).json"
CONFIG_FILE="./config_$(seth chain).json"


loadValuesFromFile $CONFIG_FILE
loadValuesFromFile $ADDRESSES_FILE

[[ -z "$GOVERNANCE" ]] && GOVERNANCE="$ETH_FROM"

message Verify root $ROOT_CONTRACT
dapp verify-contract --async 'src/root.sol:TinlakeRoot' $ROOT_CONTRACT "$ETH_FROM" "$GOVERNANCE" || true

message Verify borrower deployer $BORROWER_DEPLOYER
dapp verify-contract --async "src/borrower/deployer.sol:BorrowerDeployer" $BORROWER_DEPLOYER $ROOT_CONTRACT $TITLE_FAB $SHELF_FAB $PILE_FAB $FEED_FAB $TINLAKE_CURRENCY '"Tinlake Loan Token"' '"TLNFT"' $DISCOUNT_RATE || true

message Verify title $TITLE 
dapp verify-contract --async 'lib/tinlake-title/src/title.sol:Title' $TITLE '"Tinlake Loan Token"' '"TLNFT"' || true

message Verify pile $PILE
dapp verify-contract --async 'src/borrower/pile.sol:Pile' $PILE || true

message Verify feed $FEED
dapp verify-contract --async 'src/borrower/feed/navfeed.sol:NAVFeed' $FEED || true

message Verify shelf $SHELF
dapp verify-contract --async 'src/borrower/shelf.sol:Shelf' $SHELF $TINLAKE_CURRENCY $TITLE $PILE $FEED || true

message Verify lender deployer $LENDER_DEPLOYER
dapp verify-contract --async "src/lender/deployer.sol:LenderDeployer" $LENDER_DEPLOYER $ROOT_CONTRACT $TINLAKE_CURRENCY $TRANCHE_FAB $MEMBERLIST_FAB $RESTRICTED_TOKEN_FAB $RESERVE_FAB $ASSESSOR_FAB $COORDINATOR_FAB $OPERATOR_FAB $POOL_ADMIN_FAB $MEMBER_ADMIN $ADAPTER_DEPLOYER || true

message Verify junior tranche contracts
dapp verify-contract --async 'src/lender/token/restricted.sol:RestrictedToken' $JUNIOR_TOKEN "\"$JUNIOR_TOKEN_SYMBOL\"" "\"$JUNIOR_TOKEN_NAME\"" || true
dapp verify-contract --async 'src/lender/tranche.sol:Tranche' $JUNIOR_TRANCHE $TINLAKE_CURRENCY $JUNIOR_TOKEN || true
dapp verify-contract --async 'src/lender/token/memberlist.sol:Memberlist' $JUNIOR_MEMBERLIST || true
dapp verify-contract --async 'src/lender/operator.sol:Operator' $JUNIOR_OPERATOR $JUNIOR_TRANCHE || true

message Verify senior tranche contracts
dapp verify-contract --async 'src/lender/token/restricted.sol:RestrictedToken' $SENIOR_TOKEN "\"$SENIOR_TOKEN_SYMBOL\"" "\"$SENIOR_TOKEN_NAME\"" || true
dapp verify-contract --async 'src/lender/tranche.sol:Tranche' $SENIOR_TRANCHE $TINLAKE_CURRENCY $SENIOR_TOKEN || true
dapp verify-contract --async 'src/lender/token/memberlist.sol:Memberlist' $SENIOR_MEMBERLIST || true
dapp verify-contract --async 'src/lender/operator.sol:Operator' $SENIOR_OPERATOR $SENIOR_TRANCHE || true

message Verify reserve $RESERVE 
dapp verify-contract --async 'src/lender/reserve.sol:Reserve' $RESERVE $TINLAKE_CURRENCY || true
message Verify assessor $ASSESSOR
dapp verify-contract --async 'src/lender/assessor.sol:Assessor' $ASSESSOR || true
message Verify pool admin $POOL_ADMIN
dapp verify-contract --async 'src/lender/admin/pool.sol:PoolAdmin' $POOL_ADMIN || true
message Verify epoch coordinator $COORDINATOR
dapp verify-contract --async 'src/lender/coordinator.sol:EpochCoordinator' $COORDINATOR $CHALLENGE_TIME || true

if [ "$IS_MKR" == "true" ]; then
  message Verify adapter deployer $ADAPTER_DEPLOYER
  dapp verify-contract --async "src/lender/adapters/deployer.sol:AdapterDeployer" $ADAPTER_DEPLOYER $ROOT_CONTRACT $CLERK_FAB $MKR_MGR_FAB || true

  message Verify clerk $CLERK
  dapp verify-contract --async 'src/lender/adapters/mkr/clerk.sol:Clerk' $CLERK $MKR_DAI $SENIOR_TOKEN || true

  message TODO: verify manager manually
  echo "DAPP_SOLC_VERSION=0.5.12 dapp verify-contract --async 'src/mgr.sol:TinlakeManager' $MAKER_MGR $MKR_DAI $MKR_DAI_JOIN $SENIOR_TOKEN $SENIOR_OPERATOR $SENIOR_TRANCHE $MKR_END $MKR_VAT $MKR_VOW"
fi