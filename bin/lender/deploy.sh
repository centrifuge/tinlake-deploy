#! /usr/bin/env bash

BIN_DIR=${BIN_DIR:-$(cd "${0%/*}"&&pwd)}
source $BIN_DIR/util/util.sh
CONTRACT_BIN=$BIN_DIR/../lib/tinlake/out

cd $BIN_DIR

message Deploy Lender

DEPLOYMENT_FILE="./../deployments/addresses_$(seth chain).json"
ZERO_ADDRESS=0x0000000000000000000000000000000000000000

message Fetch Fab Addresses or Deploy

# check or deploy default fabs
OPERATOR_FAB=$(getFabContract $CONTRACT_BIN/AllowanceOperatorFab.bin "OPERATOR_FAB")
echo "OPERATOR_FAB: $OPERATOR_FAB"
ASSESSOR_FAB=$(getFabContract $CONTRACT_BIN/DefaultAssessorFab.bin "ASSESSOR_FAB")
echo "ASSESSOR_FAB: $ASSESSOR_FAB"
DISTRIBUTOR_FAB=$(getFabContract $CONTRACT_BIN/DefaultDistributorFab.bin "DISTRIBUTOR_FAB")
echo "DISTRIBUTOR_FAB: $DISTRIBUTOR_FAB"
TRANCHE_FAB=$(getFabContract $CONTRACT_BIN/TrancheFab.bin "TRANCHE_FAB")
echo "TRANCHE_FAB: $TRANCHE_FAB"

# default no senior tranche
SENIOR_TRANCHE_FAB=$ZERO_ADDRESS
SENIOR_OPERATOR_FAB=$ZERO_ADDRESS

success_msg Lender Fabs ready
TOKEN_AMOUNT_FOR_ONE=$(seth --to-uint256 1)

# backer allows lender to take currency
message create lender deployer
export LENDER_DEPLOYER=$(seth send --create $CONTRACT_BIN/LenderDeployer.bin 'LenderDeployer(address,address,uint,address,address,address,address,address,address)' $ROOT_CONTRACT $TINLAKE_CURRENCY $TOKEN_AMOUNT_FOR_ONE $TRANCHE_FAB $ASSESSOR_FAB $OPERATOR_FAB $DISTRIBUTOR_FAB $SENIOR_TRANCHE_FAB $SENIOR_OPERATOR_FAB)

message deploy assessor contract
seth send $LENDER_DEPLOYER 'deployAssessor()'
message deploy distributor contract
seth send $LENDER_DEPLOYER 'deployDistributor()'
message deploy junior tranche contract
seth send $LENDER_DEPLOYER 'deployJuniorTranche()'
message deploy junior operator
seth send $LENDER_DEPLOYER 'deployJuniorOperator()'

if [ "$SENIOR_TRANCHE_FAB"  !=  "$ZERO_ADDRESS" ]; then
    seth send $LENDER_DEPLOYER 'deploySeniorTranche()'
    seth send $LENDER_DEPLOYER 'deploySeniorOperator()'
fi
message "finalize lender contracts"
seth send $LENDER_DEPLOYER 'deploy()'

success_msg Lender Contracts deployed

JUNIOR="$(seth call $LENDER_DEPLOYER 'junior()(address)')"
JUNIOR_TOKEN="$(seth call $JUNIOR 'token()(address)')"
SENIOR="$(seth call $LENDER_DEPLOYER 'senior()(address)')"

if [ "$SENIOR_TRANCHE_FAB"  !=  "$ZERO_ADDRESS" ]; then
    SENIOR_TOKEN="$(seth call $SENIOR 'token()(address)')"
else
    SENIOR_TOKEN="$ZERO_ADDRESS"
fi

#touch $DEPLOYMENT_FILE
addValuesToFile $DEPLOYMENT_FILE <<EOF
{
    "LENDER_DEPLOYER"    :  "$LENDER_DEPLOYER",
    "OPERATOR_FAB"       :  "$OPERATOR_FAB",
    "ASSESSOR_FAB"       :  "$ASSESSOR_FAB",
    "DISTRIBUTOR_FAB"    :  "$DISTRIBUTOR_FAB",
    "TRANCHE_FAB"        :  "$TRANCHE_FAB",
    "SENIOR_TRANCHE_FAB" :  "$SENIOR_TRANCHE_FAB",
    "SENIOR_OPERATOR_FAB":  "$SENIOR_OPERATOR_FAB",
    "JUNIOR_OPERATOR"    :  "$(seth call $LENDER_DEPLOYER 'juniorOperator()(address)')",
    "JUNIOR"             :  "$JUNIOR",
    "JUNIOR_TOKEN"       :  "$JUNIOR_TOKEN",
    "SENIOR"             :  "$SENIOR",
    "SENIOR_TOKEN"       :  "$SENIOR_TOKEN",
    "SENIOR_OPERATOR"    :  "$(seth call $LENDER_DEPLOYER 'seniorOperator()(address)')",
    "DISTRIBUTOR"        :  "$(seth call $LENDER_DEPLOYER 'distributor()(address)')",
    "ASSESSOR"           :  "$(seth call $LENDER_DEPLOYER 'assessor()(address)')"
}
EOF
