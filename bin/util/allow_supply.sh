#! /usr/bin/env bash

# fetch arguments
for arg in "$@"
do
    case $arg in
        -s=*|--supply=*)
        SUPPLY="${arg#*=}"
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
echo "Supply Allowed : $SUPPLY"

message Update
if [ "$SUPPLY"  ==  "true" ]; then
    FLAG=1
else
    FLAG=0
fi

WHAT=$(seth --to-bytes32 $(seth --from-ascii "supplyAllowed"))
echo $WHAT
seth send $SENIOR_OPERATOR 'file(bytes32,bool)' $WHAT $FLAG

message New Value

echo "SupplyAllowed: $(seth call $SENIOR_OPERATOR 'supplyAllowed()(bool)')"





