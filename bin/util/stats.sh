#! /usr/bin/env bash

# fetch arguments
for arg in "$@"
do
    case $arg in
        -d=*|--deployment=*)
        ROOT_CONTRACT="${arg#*=}"
        shift
        ;;
        -s=*|--seniorOperator=*)
        SENIOR_OPERATOR="${arg#*=}"
        shift
        ;;
    esac
done

BIN_DIR=${BIN_DIR:-$(cd "${0%/*}"&&pwd)}
source $BIN_DIR/util.sh
cd $BIN_DIR

[ -z "$ROOT_CONTRACT" ] && echo -e "Usage: stats -d, --deployment=<root contract address>  Enter Tinlake root contract address" && exit

message Tinlake Stats
echo -e "Root Contract:         $ROOT_CONTRACT"
echo -e "Chain:                 $(seth chain)"

LENDER_DEPLOYER=$(seth call $ROOT_CONTRACT 'lenderDeployer()(address)')
JUNIOR_OPERATOR=$(seth call $LENDER_DEPLOYER 'juniorOperator()(address)')
[ -z "$SENIOR_OPERATOR" ] && SENIOR_OPERATOR=$(seth call $LENDER_DEPLOYER 'seniorOperator()(address)')
SENIOR=$(seth call $LENDER_DEPLOYER 'senior()(address)')
JUNIOR=$(seth call $LENDER_DEPLOYER 'junior()(address)')
ASSESSOR=$(seth call $LENDER_DEPLOYER 'assessor()(address)')

message Borrowers
BORROWER_DEPLOYER=$(seth call $ROOT_CONTRACT 'borrowerDeployer()(address)')
PILE=$(seth call $BORROWER_DEPLOYER 'pile()(address)')
TOTAL_DEBT=
echo -e "Total Debt:            $(seth --from-wei $(seth call $PILE 'total()(uint)')) DAI"

message Lenders
SENIOR_ASSET_VALUE=$(seth --from-wei $(seth call $ASSESSOR 'calcAssetValue(address)(uint)' $SENIOR))
echo -e "Current TIN Ratio:     $(./from-ray $(seth call $ASSESSOR 'currentJuniorRatio()(uint)'))"
echo -e "Minimum TIN Ratio:     $(./from-ray $(seth call $ASSESSOR 'minJuniorRatio()(uint)'))"

message Senior Tranche
echo -e "Senior Asset Value:    $(seth --from-wei $(seth call $ASSESSOR 'calcAssetValue(address)(uint)' $SENIOR)) DAI"
echo -e "Senior Interest Rate:  $(./from-ray $(seth call $SENIOR 'ratePerSecond()(uint)')) per Second"
echo -e "Senior Debt:           $(seth --from-wei $(seth call $SENIOR 'debt()(uint)')) DAI"
echo -e "DROP Price:            $(./from-ray $(seth call $ASSESSOR 'calcTokenPrice(address)(uint)' $SENIOR)) DAI "
echo -e "Senior Reserve:        $(seth --from-wei $(seth call $SENIOR 'balance()(uint)')) DAI"
echo -e "Total DROP Supply:     $(seth --from-wei $(seth call $SENIOR 'tokenSupply()(uint)')) DROP"

message Junior Tranche
echo -e "Junior Asset Value:    $(seth --from-wei $(seth call $ASSESSOR 'calcAssetValue(address)(uint)' $JUNIOR)) DAI"
echo -e "TIN Price:             $(./from-ray $(seth call $ASSESSOR 'calcTokenPrice(address)(uint)' $JUNIOR)) DAI "
echo -e "Junior Reserve:        $(seth --from-wei $(seth call $JUNIOR 'balance()(uint)')) DAI"
echo -e "Total TIN Supply:      $(seth --from-wei $(seth call $JUNIOR 'tokenSupply()(uint)')) TIN"

message Senior Prop Operator
echo -e "Total DROP Principal:  $(seth --from-wei $(seth call $SENIOR_OPERATOR 'totalPrincipal()(uint)')) DAI"
echo -e "Principal Returned:    $(seth --from-wei $(seth call $SENIOR_OPERATOR 'totalCurrencyReturned()(uint)')) DAI"
echo -e "Currency Returned:     $(seth --from-wei $(seth call $SENIOR_OPERATOR 'totalPrincipalReturned()(uint)')) DAI"









