#! /usr/bin/env bash

set -e

BIN_DIR=${BIN_DIR:-$(cd "${0%/*}"&&pwd)}
source $BIN_DIR/util/util.sh
export DAPP_JSON=$BIN_DIR/../lib/tinlake/out/dapp.sol.json
export DAPP_ROOT=$BIN_DIR/../lib/tinlake

cd $BIN_DIR

message Deploy Adapter

CLERK_FAB=$(getFabContract src/lender/adapters/mkr/fabs/clerk.sol ClerkFab "CLERK_FAB")
message "CLERK_FAB: $CLERK_FAB"

# contract deployment
success_msg Adapter Fabs ready

message create adapter deployer
export ADAPTER_DEPLOYER=$(dapp create "src/lender/adapters/deployer.sol:AdapterDeployer" $ROOT_CONTRACT $CLERK_FAB)

message "Init Adapter Deployer"
MIN_SENIOR_RATIO=$(seth --to-uint256 $MIN_SENIOR_RATIO)
MAX_SENIOR_RATIO=$(seth --to-uint256 $MAX_SENIOR_RATIO)
MAX_RESERVE=$(seth --to-uint256 $MAX_RESERVE)
CHALLENGE_TIME=$(seth --to-uint256 $CHALLENGE_TIME)
SENIOR_INTEREST_RATE=$(seth --to-uint256 $SENIOR_INTEREST_RATE)

$(seth send $ADAPTER_DEPLOYER 'init(address,address,address,address,address,address,address,address,uint)' $LENDER_DEPLOYER $MKR_MGR $MKR_SPOTTER $MKR_VAT $MKR_JUG $MKR_URN $MKR_LIQ $MKR_END $MKR_MAT_BUFFER)

message wire adapter
seth send $ADAPTER_DEPLOYER 'wireAdapter()'

addValuesToFile $DEPLOYMENT_FILE <<EOF
{
    "ADAPTER_DEPLOYER"    :  "$ADAPTER_DEPLOYER",
    "CLERK_FAB"           :  "$CLERK_FAB",
    "MAKER_MGR"           :  "$MKR_MGR",
    "MKR_VAT"             :  "$MKR_VAT",
    "MKR_JUG"             :  "$MKR_JUG",
    "CLERK"               :  "$CLERK"
}
EOF
