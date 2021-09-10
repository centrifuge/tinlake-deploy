#! /usr/bin/env bash

set -e

BIN_DIR=${BIN_DIR:-$(cd "${0%/*}"&&pwd)}
source $BIN_DIR/util/util.sh
export DAPP_JSON=$BIN_DIR/../lib/tinlake/out/dapp.sol.json
export DAPP_ROOT=$BIN_DIR/../lib/tinlake

cd $BIN_DIR

DEPLOYMENT_FILE="./../deployments/addresses_$(seth chain).json"
ZERO_ADDRESS=0x0000000000000000000000000000000000000000

message Deploy lender fabs

RESERVE_FAB=$(getFabContract src/lender/fabs/reserve.sol ReserveFab "RESERVE_FAB")
echo "RESERVE_FAB = $RESERVE_FAB"

ASSESSOR_FAB=$(getFabContract src/lender/fabs/assessor.sol AssessorFab "ASSESSOR_FAB")
echo "ASSESSOR_FAB = $ASSESSOR_FAB"

POOL_ADMIN_FAB=$(getFabContract src/lender/fabs/pooladmin.sol PoolAdminFab "POOL_ADMIN_FAB")
echo "POOL_ADMIN_FAB = $POOL_ADMIN_FAB"

TRANCHE_FAB=$(getFabContract src/lender/fabs/tranche.sol TrancheFab "TRANCHE_FAB")
echo "TRANCHE_FAB = $TRANCHE_FAB"

MEMBERLIST_FAB=$(getFabContract src/lender/fabs/memberlist.sol MemberlistFab "MEMBERLIST_FAB")
echo "MEMBERLIST_FAB = $MEMBERLIST_FAB"

RESTRICTED_TOKEN_FAB=$(getFabContract src/lender/fabs/restrictedtoken.sol RestrictedTokenFab "RESTRICTED_TOKEN_FAB")
echo "RESTRICTED_TOKEN_FAB = $RESTRICTED_TOKEN_FAB"

OPERATOR_FAB=$(getFabContract src/lender/fabs/operator.sol OperatorFab "OPERATOR_FAB")
echo "OPERATOR_FAB = $OPERATOR_FAB"

COORDINATOR_FAB=$(getFabContract src/lender/fabs/coordinator.sol CoordinatorFab "COORDINATOR_FAB")
echo "COORDINATOR_FAB = $COORDINATOR_FAB"

if [ "$IS_MKR" == "true" ]; then
    CLERK_FAB=$(getFabContract src/lender/adapters/mkr/fabs/clerk.sol ClerkFab "CLERK_FAB")
    echo "CLERK_FAB = $CLERK_FAB"
fi

# contract deployment
if [ "$IS_MKR" == "true" ]; then
    if [[ -n "$LENDER_DEPLOYER" ]]; then
        ADAPTER_DEPLOYER=$(seth call $LENDER_DEPLOYER 'adapterDeployer()(address)')
    else
        message Create adapter deployer
        ADAPTER_DEPLOYER=$(dapp create "src/lender/adapters/deployer.sol:AdapterDeployer" $ROOT_CONTRACT $CLERK_FAB $MKR_MGR_FAB)
    fi
    echo "ADAPTER_DEPLOYER = $ADAPTER_DEPLOYER"
else
    ADAPTER_DEPLOYER=0x0000000000000000000000000000000000000000
fi

## backer allows lender to take currency

message Create lender deployer
[[ -z "$LENDER_DEPLOYER" ]] && LENDER_DEPLOYER=$(dapp create "src/lender/deployer.sol:LenderDeployer" $ROOT_CONTRACT $TINLAKE_CURRENCY $TRANCHE_FAB $MEMBERLIST_FAB $RESTRICTED_TOKEN_FAB $RESERVE_FAB $ASSESSOR_FAB $COORDINATOR_FAB $OPERATOR_FAB $POOL_ADMIN_FAB $MEMBER_ADMIN $ADAPTER_DEPLOYER)
echo "LENDER_DEPLOYER = $LENDER_DEPLOYER"

message Init lender deployer
MIN_SENIOR_RATIO=$(seth --to-uint256 $MIN_SENIOR_RATIO)
MAX_SENIOR_RATIO=$(seth --to-uint256 $MAX_SENIOR_RATIO)
MAX_RESERVE=$(seth --to-uint256 $MAX_RESERVE)
CHALLENGE_TIME=$(seth --to-uint256 $CHALLENGE_TIME)
SENIOR_INTEREST_RATE=$(seth --to-uint256 $SENIOR_INTEREST_RATE)

DEPLOYER="$(seth call $LENDER_DEPLOYER 'deployer()(address)')"
if [ "$DEPLOYER" == "$ETH_FROM" ]; then
    seth send $LENDER_DEPLOYER 'init(uint,uint,uint,uint,uint,string,string,string,string)' $MIN_SENIOR_RATIO $MAX_SENIOR_RATIO $MAX_RESERVE $CHALLENGE_TIME $SENIOR_INTEREST_RATE "\"$SENIOR_TOKEN_NAME\"" "\"$SENIOR_TOKEN_SYMBOL\"" "\"$JUNIOR_TOKEN_NAME\"" "\"$JUNIOR_TOKEN_SYMBOL\""
fi

addValuesToFile $DEPLOYMENT_FILE <<EOF
{
    "LENDER_DEPLOYER"    :  "$LENDER_DEPLOYER",
    "ADAPTER_DEPLOYER"   :  "$ADAPTER_DEPLOYER"
}
EOF

message Deploy lender contracts

JUNIOR_TRANCHE=$(seth call $LENDER_DEPLOYER 'juniorTranche()(address)')
if [ "$JUNIOR_TRANCHE" == "$ZERO_ADDRESS" ]; then
    seth send $LENDER_DEPLOYER 'deployJunior()'
    JUNIOR_TRANCHE=$(seth call $LENDER_DEPLOYER 'juniorTranche()(address)')
fi
JUNIOR_TOKEN=$(seth call $LENDER_DEPLOYER 'juniorToken()(address)')
JUNIOR_OPERATOR=$(seth call $LENDER_DEPLOYER 'juniorOperator()(address)')
JUNIOR_MEMBERLIST=$(seth call $LENDER_DEPLOYER 'juniorMemberlist()(address)')
echo "JUNIOR_TRANCHE = $JUNIOR_TRANCHE"
echo "JUNIOR_TOKEN = $JUNIOR_TOKEN"
echo "JUNIOR_OPERATOR = $JUNIOR_OPERATOR"
echo "JUNIOR_MEMBERLIST = $JUNIOR_MEMBERLIST"

SENIOR_TRANCHE=$(seth call $LENDER_DEPLOYER 'seniorTranche()(address)')
if [ "$SENIOR_TRANCHE" == "$ZERO_ADDRESS" ]; then
    seth send $LENDER_DEPLOYER 'deploySenior()'
    SENIOR_TRANCHE=$(seth call $LENDER_DEPLOYER 'seniorTranche()(address)')
fi
SENIOR_TOKEN=$(seth call $LENDER_DEPLOYER 'seniorToken()(address)')
SENIOR_OPERATOR=$(seth call $LENDER_DEPLOYER 'seniorOperator()(address)')
SENIOR_MEMBERLIST=$(seth call $LENDER_DEPLOYER 'seniorMemberlist()(address)')
echo "SENIOR_TRANCHE = $SENIOR_TRANCHE"
echo "SENIOR_TOKEN = $SENIOR_TOKEN"
echo "SENIOR_OPERATOR = $SENIOR_OPERATOR"
echo "SENIOR_MEMBERLIST = $SENIOR_MEMBERLIST"

RESERVE=$(seth call $LENDER_DEPLOYER 'reserve()(address)')
if [ "$RESERVE" == "$ZERO_ADDRESS" ]; then
    seth send $LENDER_DEPLOYER 'deployReserve()'
    RESERVE=$(seth call $LENDER_DEPLOYER 'reserve()(address)')
fi
echo "RESERVE = $RESERVE"

ASSESSOR=$(seth call $LENDER_DEPLOYER 'assessor()(address)')
if [ "$ASSESSOR" == "$ZERO_ADDRESS" ]; then
    seth send $LENDER_DEPLOYER 'deployAssessor()'
    ASSESSOR=$(seth call $LENDER_DEPLOYER 'assessor()(address)')
fi
echo "ASSESSOR = $ASSESSOR"

POOL_ADMIN=$(seth call $LENDER_DEPLOYER 'poolAdmin()(address)')
if [ "$POOL_ADMIN" == "$ZERO_ADDRESS" ]; then
    seth send $LENDER_DEPLOYER 'deployPoolAdmin()'
    POOL_ADMIN=$(seth call $LENDER_DEPLOYER 'poolAdmin()(address)')
fi
echo "POOL_ADMIN = $POOL_ADMIN"

COORDINATOR=$(seth call $LENDER_DEPLOYER 'coordinator()(address)')
if [ "$COORDINATOR" == "$ZERO_ADDRESS" ]; then
    seth send $LENDER_DEPLOYER 'deployCoordinator()'
    COORDINATOR=$(seth call $LENDER_DEPLOYER 'coordinator()(address)')
fi
echo "COORDINATOR = $COORDINATOR"

WIRED="$(seth call $LENDER_DEPLOYER 'wired()(bool)')"
if [ "$WIRED" == "false" ]; then
    message Wire lender contracts
    seth send $LENDER_DEPLOYER 'deploy()'
fi

if [ "$IS_MKR" == "true" ]; then
    message Deploy maker contracts

    CLERK=$(seth call $ADAPTER_DEPLOYER 'clerk()(address)')
    if [ "$CLERK" == "$ZERO_ADDRESS" ]; then
        seth send $ADAPTER_DEPLOYER 'deployClerk(address,bool)' $LENDER_DEPLOYER $WIRE_CLERK
        CLERK=$(seth call $ADAPTER_DEPLOYER 'clerk()(address)')
    fi
    echo "CLERK = $CLERK"

    MAKER_GMR=$(seth call $ADAPTER_DEPLOYER 'mgr()(address)')
    if [ "$MAKER_GMR" == "$ZERO_ADDRESS" ]; then
        seth send $ADAPTER_DEPLOYER 'deployMgr(address,address,address,address,address,address,address,address,uint)' $MKR_DAI $MKR_DAI_JOIN $MKR_END $MKR_VAT $MKR_VOW $MKR_LIQ $MKR_SPOTTER $MKR_JUG $MKR_MAT_BUFFER
        MAKER_GMR=$(seth call $ADAPTER_DEPLOYER 'clerk()(address)')
    fi
    echo "MAKER_GMR = $MAKER_GMR"
fi

addValuesToFile $DEPLOYMENT_FILE <<EOF
{
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
    "MEMBER_ADMIN"       :  "$MEMBER_ADMIN",
    "MAKER_MGR"          :  "$MAKER_MGR",
    "MKR_VAT"            :  "$MKR_VAT",
    "MKR_JUG"            :  "$MKR_JUG",
    "CLERK"              :  "$CLERK"
}
EOF
