#! /usr/bin/env bash

# Define ENV
GETH_DIR=$HOME/.dapp/testnet/8545
mkdir -p $GETH_DIR

# Default Test Config
touch $GETH_DIR/.empty-password

test -z "$ETH_RPC_URL" && ETH_RPC_URL=http://127.0.0.1:8545
test -z "$ETH_KEYSTORE" && ETH_KEYSTORE=$GETH_DIR/keystore
test -z "$ETH_PASSWORD" && CURRENCY_VERSION=$GETH_DIR/.empty-password
test -z "$ETH_FROM" && ETH_FROM=$(cat $GETH_DIR/keystore/* | jq -r '.address' | head -n 1)
test -z "$ETH_GAS" && export ETH_GAS=10000000
