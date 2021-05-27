#! /usr/bin/env bash

ZERO_ADDRESS=0x0000000000000000000000000000000000000000

message() {

    echo
    echo -----------------------------------------------------------------------------
    echo "$@"
    echo -----------------------------------------------------------------------------
    echo
}

success_msg()
{
    echo -----------------------------------------------------------------------------
    echo -e "\e[0;32m >>> $@ \e[0m"
    echo -----------------------------------------------------------------------------
}

msg()
{
 echo ">>> $@"
}


error_exit()
{
    echo -----------------------------------------------------------------------------
    echo -e "\e[0;31m >>> Error $@"
    echo -----------------------------------------------------------------------------
    exit 1
}

warning_msg()
{
    echo -----------------------------------------------------------------------------
    echo -e "\e[0;33m >>> Warning $@ \e[0m"
    echo -----------------------------------------------------------------------------
}

loadValuesFromFile() {
    local keys

    keys=$(jq -r "keys_unsorted[]" "$1")
    for KEY in $keys; do
        VALUE=$(jq -r ".$KEY" "$1")
        eval "export $KEY='$VALUE'"
    done
}

addValuesToFile() {
    result=$(jq -s add "$1" /dev/stdin)
    printf %s "$result" > "$1"
}

getContractCode() {
    echo 0x$(cat $DAPP_JSON | jq -r ".contracts[\"$1\"][\"$2\"].evm.bytecode.object")
}


getFabContract() {
    CONTRACT_CODE=$(getContractCode $1 $2)
    SALT=$(seth --to-bytes32 $(seth --from-ascii $3))
    FAB_ADDR="${!3}"
    if [ -z "$FAB_ADDR" ]
    then
        # check if fab bytecode is already deployed at the network
        # Tinlake fabs have a deterministic address based on the create2 opcode
        BYTECODE_HASH=$(seth call $MAIN_DEPLOYER 'bytecodeHash(bytes)(bytes32)' $CONTRACT_CODE)
        FAB_ADDR=$(seth call $MAIN_DEPLOYER 'getAddress(bytes32,bytes32)(address)' $BYTECODE_HASH $SALT)
        if [ "$FAB_ADDR"  ==  "$ZERO_ADDRESS" ]; then
            echo "Deploying Fab: $3" > /dev/stderr
            seth send $MAIN_DEPLOYER 'deploy(bytes,bytes32)(address)' $CONTRACT_CODE $SALT
            FAB_ADDR=$(seth call $MAIN_DEPLOYER 'getAddress(bytes32,bytes32)(address)' $BYTECODE_HASH $SALT)
        fi
    else
        echo "Using $3 address from config file" > /dev/stderr
    fi
    echo $FAB_ADDR
}