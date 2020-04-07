DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
BIN_DIR=${BIN_DIR:-$(cd "${0%/*}"&&pwd)}
cd $BIN_DIR

source ./../util/util.sh

## set SETH enviroment variable
source ./local_env.sh

DEPLOYMENT_FILE=$1
[ -z "$1" ] && DEPLOYMENT_FILE="./../../deployments/addresses_$(seth chain).json"

realpath $DEPLOYMENT_FILE

loadValuesFromFile $DEPLOYMENT_FILE

# get some currency
AMOUNT=$(seth --to-uint256 $(seth --to-wei 1000 ether))
seth send $TINLAKE_CURRENCY 'mint(address, uint)' $ETH_FROM $AMOUNT

seth send $JUNIOR_OPERATOR 'relyInvestor(address)' $ETH_FROM
