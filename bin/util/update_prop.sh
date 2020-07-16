#! /usr/bin/env bash

function totalReturned {
  echo "Total Currency Returned: $(seth call $SENIOR_OPERATOR 'totalCurrencyReturned()(uint)')"
  echo "Total Principal Returned: $(seth call $SENIOR_OPERATOR 'totalPrincipalReturned()(uint)')"
}

# fetch arguments
for arg in "$@"
do
    case $arg in
        -p=*|--principal=*)
        PRINCIPAL="${arg#*=}"
        shift
        ;;
        -c=*|--currency=*)
        CURRENCY="${arg#*=}"
        shift
        ;;
    esac
done

BIN_DIR=${BIN_DIR:-$(cd "${0%/*}"&&pwd)}
source $BIN_DIR/util.sh

cd $BIN_DIR
ADDRESSES="./../../deployments/addresses_$(seth chain).json"

loadValuesFromFile $ADDRESSES
message Input Data
echo "New Currency Returned : $CURRENCY"
echo "New Prinicipal Returned : $PRINCIPAL"

message Current Values
totalReturned

message Update
seth send $SENIOR_OPERATOR 'updateReturned(uint,uint)' $CURRENCY $PRINCIPAL

message New Values
totalReturned




