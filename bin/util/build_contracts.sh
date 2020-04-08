# script builds contracts into multiple files
# by using dapp build --extracts
# individual files are required for the deploy scripts
BIN_DIR=${BIN_DIR:-$(cd "${0%/*}"&&pwd)}
cd $BIN_DIR

CONTRACT_FILES=1
if [ -d "./../../out" ]; then
# count contract abi files
CONTRACT_FILES=$(ls ./../../out | wc -l)
fi

# build contracts if required
if [ "$CONTRACT_FILES" -lt  "2" ]; then
    cd ../..
    echo $(pwd)
    dapp update
    dapp --use solc:0.5.15 build --extract
    cd  lib/tinlake
    dapp update
    dapp --use solc:0.5.15 build --extract
    cd ../..
fi
echo "Contract build done"
