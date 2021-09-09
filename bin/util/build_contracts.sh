#! /usr/bin/env bash

# script builds contracts into multiple files
# by using dapp build --extracts
# individual files are required for the deploy scripts

set -e

BIN_DIR=${BIN_DIR:-$(cd "${0%/*}"&&pwd)}
cd $BIN_DIR

export DAPP_SOLC_VERSION=0.7.6

cd ../..
dapp update
dapp build
cd  lib/tinlake
dapp update
dapp build

echo "Contract build done"
