#! /usr/bin/env bash

set -e

BIN_DIR=${BIN_DIR:-$(cd "${0%/*}"&&pwd)}
source $BIN_DIR/util/util.sh
CONTRACT_BIN=$BIN_DIR/../lib/tinlake/out

cd $BIN_DIR

message Deploy Lender

DEPLOYMENT_FILE="./../deployments/addresses_$(seth chain).json"
ZERO_ADDRESS=0x0000000000000000000000000000000000000000

message Fetch Fab Addresses or Deploy

RESERVE_FAB=$(getFabContract $CONTRACT_BIN/ReserveFab.bin "RESERVE_FAB")
message "RESERVE_FAB: $RESERVE_FAB"

ASSESSOR_FAB=$(getFabContract $CONTRACT_BIN/AssessorFab.bin "ASSESSOR_FAB")
message "ASSESSOR_FAB: $ASSESSOR_FAB"

TRANCHE_FAB=$(getFabContract $CONTRACT_BIN/TrancheFab.bin "TRANCHE_FAB")
message "TRANCHE_FAB: $TRANCHE_FAB"

MEMBERLIST_FAB=$(getFabContract $CONTRACT_BIN/MemberlistFab.bin "MEMBERLIST_FAB")
message "MEMBERLIST_FAB: $MEMBERLIST_FAB"

OPERATOR_FAB=$(getFabContract $CONTRACT_BIN/OperatorFab.bin "OPERATOR_FAB")
message "OPERATOR_FAB: $OPERATOR_FAB"

COORDINATOR_FAB=$(getFabContract $CONTRACT_BIN/CoordinatorFab.bin "COORDINATOR_FAB")
message "COORDINATOR_FAB: $COORDINATOR_FAB"

# contract deployment
success_msg Lender Fabs ready

[[ -z "$JUNIOR_TOKEN_NAME" ]] && JUNIOR_TOKEN_NAME="TIN Token"
[[ -z "$JUNIOR_TOKEN_SYMBOL" ]] && JUNIOR_TOKEN_SYMBOL="TIN"
[[ -z "$SENIOR_TOKEN_NAME" ]] && SENIOR_TOKEN_NAME="DROP Token"
[[ -z "$SENIOR_TOKEN_SYMBOL" ]] && SENIOR_TOKEN_SYMBOL="DROP"

## backer allows lender to take currency
message create lender deployer
export LENDER_DEPLOYER=$(seth send --create $CONTRACT_BIN/LenderDeployer.bin 'LenderDeployer(address,address,address,address,address,address,address,address)' $ROOT_CONTRACT $TINLAKE_CURRENCY $TRANCHE_FAB $MEMBERLIST_FAB $RESERVE_FAB $ASSESSOR_FAB $COORDINATOR_FAB $OPERATOR_FAB)

message "Init Lender Deployer"
MIN_SENIOR_RATIO=$(seth --to-uint256 $MIN_SENIOR_RATIO)
MAX_SENIOR_RATIO=$(seth --to-uint256 $MAX_SENIOR_RATIO)
MAX_RESERVE=$(seth --to-uint256 $MAX_RESERVE)
CHALLENGE_TIME=$(seth --to-uint256 $CHALLENGE_TIME)
SENIOR_INTEREST_RATE=$(seth --to-uint256 $SENIOR_INTEREST_RATE)
seth send $LENDER_DEPLOYER 'init(uint,uint,uint,uint,uint, string memory,string memory,string memory,string memory)' $MIN_SENIOR_RATIO $MAX_SENIOR_RATIO $MAX_RESERVE $CHALLENGE_TIME $SENIOR_INTEREST_RATE "$SENIOR_TOKEN_NAME" "$SENIOR_TOKEN_SYMBOL" "$JUNIOR_TOKEN_NAME" "$JUNIOR_TOKEN_SYMBOL"

message deploy tranches
seth send $LENDER_DEPLOYER 'deployJunior()'
seth send $LENDER_DEPLOYER 'deploySenior()'
message deploy reserve
seth send $LENDER_DEPLOYER 'deployReserve()'
message deploy assessor
seth send $LENDER_DEPLOYER 'deployAssessor()'
message deploy coordinator
seth send $LENDER_DEPLOYER 'deployCoordinator()'
message lender deployer rely/depend/file
seth send $LENDER_DEPLOYER 'deploy()'

addValuesToFile $DEPLOYMENT_FILE <<EOF
{
    "LENDER_DEPLOYER"    :  "$LENDER_DEPLOYER",
    "OPERATOR_FAB"       :  "$OPERATOR_FAB",
    "ASSESSOR_FAB"       :  "$ASSESSOR_FAB",
    "COORDINATOR_FAB"    :  "$COORDINATOR_FAB",
    "TRANCHE_FAB"        :  "$TRANCHE_FAB",
    "MEMBERLIST_FAB"     :  "$MEMBERLIST_FAB",
    "RESERVE_FAB"        :  "$RESERVE_FAB",
    "JUNIOR_OPERATOR"    :  "$(seth call $LENDER_DEPLOYER 'juniorOperator()(address)')",
    "SENIOR_OPERATOR"    :  "$(seth call $LENDER_DEPLOYER 'seniorOperator()(address)')",
    "JUNIOR_TRANCHE"     :  "$(seth call $LENDER_DEPLOYER 'juniorTranche()(address)')",
    "SENIOR_TRANCHE"     :  "$(seth call $LENDER_DEPLOYER 'seniorTranche()(address)')",
    "JUNIOR_TOKEN"       :  "$(seth call $LENDER_DEPLOYER 'juniorToken()(address)')",
    "SENIOR_TOKEN"       :  "$(seth call $LENDER_DEPLOYER 'seniorToken()(address)')",
    "ASSESSOR"           :  "$(seth call $LENDER_DEPLOYER 'assessor()(address)')",
    "COORDINATOR"        :  "$(seth call $LENDER_DEPLOYER 'coordinator()(address)')",
    "RESERVE"            :  "$(seth call $LENDER_DEPLOYER 'reserve()(address)')"
}
EOF
