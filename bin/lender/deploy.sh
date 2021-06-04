#! /usr/bin/env bash

set -e

BIN_DIR=${BIN_DIR:-$(cd "${0%/*}"&&pwd)}
source $BIN_DIR/util/util.sh
export DAPP_JSON=$BIN_DIR/../lib/tinlake/out/dapp.sol.json
export DAPP_ROOT=$BIN_DIR/../lib/tinlake

cd $BIN_DIR

message Deploy Lender

DEPLOYMENT_FILE="./../deployments/addresses_$(seth chain).json"
ZERO_ADDRESS=0x0000000000000000000000000000000000000000

message Fetch Fab Addresses or Deploy

RESERVE_FAB=$(getFabContract src/lender/fabs/reserve.sol ReserveFab "RESERVE_FAB")
message "RESERVE_FAB: $RESERVE_FAB"

ASSESSOR_FAB=$(getFabContract src/lender/fabs/assessor.sol AssessorFab "ASSESSOR_FAB")
message "ASSESSOR_FAB: $ASSESSOR_FAB"

POOL_ADMIN_FAB=$(getFabContract src/lender/fabs/pooladmin.sol PoolAdminFab "POOL_ADMIN_FAB")
message "POOL_ADMIN_FAB: $POOL_ADMIN_FAB"

TRANCHE_FAB=$(getFabContract src/lender/fabs/tranche.sol TrancheFab "TRANCHE_FAB")
message "TRANCHE_FAB: $TRANCHE_FAB"

MEMBERLIST_FAB=$(getFabContract src/lender/fabs/memberlist.sol MemberlistFab "MEMBERLIST_FAB")
message "MEMBERLIST_FAB: $MEMBERLIST_FAB"

RESTRICTED_TOKEN_FAB=$(getFabContract src/lender/fabs/restrictedtoken.sol RestrictedTokenFab "RESTRICTED_TOKEN_FAB")
message "RESTRICTED_TOKEN_FAB: $RESTRICTED_TOKEN_FAB"

OPERATOR_FAB=$(getFabContract src/lender/fabs/operator.sol OperatorFab "OPERATOR_FAB")
message "OPERATOR_FAB: $OPERATOR_FAB"

COORDINATOR_FAB=$(getFabContract src/lender/fabs/coordinator.sol CoordinatorFab "COORDINATOR_FAB")
message "COORDINATOR_FAB: $COORDINATOR_FAB"

if [ "$IS_MKR" == "true" ]; then
    CLERK_FAB=$(getFabContract src/lender/adapters/mkr/fabs/clerk.sol ClerkFab "CLERK_FAB")
    message "CLERK_FAB: $CLERK_FAB"
else
    CLERK_FAB="0x0"
fi

# contract deployment
success_msg Lender Fabs ready

[[ -z "$JUNIOR_TOKEN_NAME" ]] && JUNIOR_TOKEN_NAME="TIN-TOKEN"
[[ -z "$JUNIOR_TOKEN_SYMBOL" ]] && JUNIOR_TOKEN_SYMBOL="TIN"
[[ -z "$SENIOR_TOKEN_NAME" ]] && SENIOR_TOKEN_NAME="DROP-TOKEN"
[[ -z "$SENIOR_TOKEN_SYMBOL" ]] && SENIOR_TOKEN_SYMBOL="DROP"

## backer allows lender to take currency

if [ "$IS_MKR" == "true" ]; then
    message create lender deployer
    export LENDER_DEPLOYER=$(dapp create "src/lender/adapters/mkr/deployer.sol:MKRLenderDeployer" $ROOT_CONTRACT $TINLAKE_CURRENCY $TRANCHE_FAB $MEMBERLIST_FAB $RESTRICTED_TOKEN_FAB $RESERVE_FAB $ASSESSOR_FAB $COORDINATOR_FAB $OPERATOR_FAB $POOL_ADMIN_FAB $CLERK_FAB $MEMBER_ADMIN)
else
    message create lender deployer
    export LENDER_DEPLOYER=$(dapp create "src/lender/deployer.sol:LenderDeployer" $ROOT_CONTRACT $TINLAKE_CURRENCY $TRANCHE_FAB $MEMBERLIST_FAB $RESTRICTED_TOKEN_FAB $RESERVE_FAB $ASSESSOR_FAB $COORDINATOR_FAB $OPERATOR_FAB $POOL_ADMIN_FAB $MEMBER_ADMIN)
fi

message "Init Lender Deployer"
MIN_SENIOR_RATIO=$(seth --to-uint256 $MIN_SENIOR_RATIO)
MAX_SENIOR_RATIO=$(seth --to-uint256 $MAX_SENIOR_RATIO)
MAX_RESERVE=$(seth --to-uint256 $MAX_RESERVE)
CHALLENGE_TIME=$(seth --to-uint256 $CHALLENGE_TIME)
SENIOR_INTEREST_RATE=$(seth --to-uint256 $SENIOR_INTEREST_RATE)

$(seth send $LENDER_DEPLOYER 'init(uint,uint,uint,uint,uint,string,string,string,string)' $MIN_SENIOR_RATIO $MAX_SENIOR_RATIO $MAX_RESERVE $CHALLENGE_TIME $SENIOR_INTEREST_RATE \"$SENIOR_TOKEN_NAME\" \"$SENIOR_TOKEN_SYMBOL\" \"$JUNIOR_TOKEN_NAME\" \"$JUNIOR_TOKEN_SYMBOL\")

if [ "$IS_MKR" == "true" ]; then
    message "Init MKR Lender Deployer"
    $(seth send $LENDER_DEPLOYER 'initMKR(address, address, address, address, address, address, address, uint)' $MKR_MGR $MKR_SPOTTER $MKR_VAT $MKR_JUG $MKR_URN $MKR_LIQ $MKR_END $MKR_MAT_BUFFER)
fi

message deploy tranches
seth send $LENDER_DEPLOYER 'deployJunior()'
export JUNIOR_TRANCHE=$(seth call $LENDER_DEPLOYER 'juniorTranche()(address)')
export JUNIOR_TOKEN=$(seth call $LENDER_DEPLOYER 'juniorToken()(address)')
export JUNIOR_OPERATOR=$(seth call $LENDER_DEPLOYER 'juniorOperator()(address)')
export JUNIOR_MEMBERLIST=$(seth call $LENDER_DEPLOYER 'juniorMemberlist()(address)')

seth send $LENDER_DEPLOYER 'deploySenior()'
export SENIOR_TRANCHE=$(seth call $LENDER_DEPLOYER 'seniorTranche()(address)')
export SENIOR_TOKEN=$(seth call $LENDER_DEPLOYER 'seniorToken()(address)')
export SENIOR_OPERATOR=$(seth call $LENDER_DEPLOYER 'seniorOperator()(address)')
export SENIOR_MEMBERLIST=$(seth call $LENDER_DEPLOYER 'seniorMemberlist()(address)')

message deploy reserve
seth send $LENDER_DEPLOYER 'deployReserve()'
export RESERVE=$(seth call $LENDER_DEPLOYER 'reserve()(address)')

message deploy assessor
seth send $LENDER_DEPLOYER 'deployAssessor()'
export ASSESSOR=$(seth call $LENDER_DEPLOYER 'assessor()(address)')

message deploy pool admin
seth send $LENDER_DEPLOYER 'deployPoolAdmin()'
export POOL_ADMIN=$(seth call $LENDER_DEPLOYER 'poolAdmin()(address)')

message deploy coordinator
seth send $LENDER_DEPLOYER 'deployCoordinator()'
export COORDINATOR=$(seth call $LENDER_DEPLOYER 'coordinator()(address)')

message lender deployer rely/depend/file
seth send $LENDER_DEPLOYER 'deploy()'

addValuesToFile $DEPLOYMENT_FILE <<EOF
{
    "LENDER_DEPLOYER"    :  "$LENDER_DEPLOYER",
    "OPERATOR_FAB"       :  "$OPERATOR_FAB",
    "ASSESSOR_FAB"       :  "$ASSESSOR_FAB",
    "POOL_ADMIN_FAB"     :  "$POOL_ADMIN_FAB",
    "RESTRICTED_TOKEN_FAB" :  "$RESTRICTED_TOKEN_FAB",
    "COORDINATOR_FAB"    :  "$COORDINATOR_FAB",
    "TRANCHE_FAB"        :  "$TRANCHE_FAB",
    "MEMBERLIST_FAB"     :  "$MEMBERLIST_FAB",
    "RESERVE_FAB"        :  "$RESERVE_FAB",
    "JUNIOR_OPERATOR"    :  "$JUNIOR_OPERATOR",
    "SENIOR_OPERATOR"    :  "$SENIOR_OPERATOR",
    "JUNIOR_TRANCHE"     :  "$JUNIOR_TRANCHE",
    "SENIOR_TRANCHE"     :  "$SENIOR_TRANCHE",
    "JUNIOR_TOKEN"       :  "$JUNIOR_TOKEN",
    "SENIOR_TOKEN"       :  "$SENIOR_TOKEN",
    "JUNIOR_MEMBERLIST"  :  "$JUNIOR_MEMBERLIST",
    "SENIOR_MEMBERLIST"  :  "$SENIOR_MEMBERLIST",
    "ASSESSOR"           :  "$ASSESSOR",
    "POOL_ADMIN"         :  "$POOL_ADMIN",
    "COORDINATOR"        :  "$COORDINATOR",
    "RESERVE"            :  "$RESERVE",
    "MEMBER_ADMIN"       :  "$MEMBER_ADMIN"
}
EOF
