#! /usr/bin/env bash

BIN_DIR=${BIN_DIR:-$(cd "${0%/*}"&&pwd)}
source $BIN_DIR/util/util.sh

# Env vars
message Enviroment Variables

if [[ -z "$ETH_RPC_URL" ]]; then
    error_exit "ETH_RPC_URL is not defined"
fi
echo "RPC URL = $ETH_RPC_URL"

if [[ -z "$ETH_FROM" ]]; then
    error_exit "ETH_FROM is not defined"
fi
echo "Account = $ETH_FROM"

printf "\n"

if [[ -z "$ETH_GAS" ]]; then
    warning_msg "ETH_GAS is not defined"
fi
echo "Gas limit = $(printf %.0f $(echo "$ETH_GAS/10^6" | bc -l)) million"

if [[ -z "$ETH_GAS_PRICE" ]]; then
    error_exit "ETH_GAS_PRICE is not defined"
fi

if [[ -z "$ETH_PRIO_FEE" ]]; then
    echo "WARN: Not using EIP 1559 transactions, since ETH_PRIO_FEE is not defined"
    echo "Fee Per Gas = $(printf %.0f $(echo "$ETH_GAS_PRICE/10^9" | bc -l)) gwei"
else
    echo "Max Priority Fee Per Gas = $(printf %.0f $(echo "$ETH_PRIO_FEE/10^9" | bc -l)) gwei"
    echo "Max Fee Per Gas = $(printf %.0f $(echo "$ETH_GAS_PRICE/10^9" | bc -l)) gwei"
fi

printf "\n"

echo "Solidity version = $(echo $DAPP_SOLC_VERSION)"
echo "Network = $(seth chain)"
echo "Balance = $(echo "$(seth balance $ETH_FROM)/10^18" | bc -l) ETH"

# Addresses
message Contract Addresses

if [[ -z "$TINLAKE_CURRENCY" ]]; then
    error_exit "TINLAKE_CURRENCY is not defined"
fi
echo "TINLAKE_CURRENCY = $(seth call $TINLAKE_CURRENCY 'symbol()(string)')"

if [[ -z "$GOVERNANCE" ]]; then
    error_exit "GOVERNANCE is not defined"
fi
echo "GOVERNANCE = $GOVERNANCE"

if [[ -z "$MAIN_DEPLOYER" ]]; then
    error_exit "MAIN_DEPLOYER is not defined"
fi
echo "MAIN_DEPLOYER = $MAIN_DEPLOYER"

if [[ -z "$MEMBER_ADMIN" ]]; then
    error_exit "MEMBER_ADMIN is not defined"
fi
echo "MEMBER_ADMIN = $MEMBER_ADMIN"

# Tinlake vars
message Tinlake Variables
if [[ -z "$SENIOR_INTEREST_RATE" ]]; then
    error_exit "SENIOR_INTEREST_RATE is not defined"
fi
echo "SENIOR_INTEREST_RATE = $(printf %.2f $(echo "(($SENIOR_INTEREST_RATE-10^27)*(60 * 60 * 24 * 365))/10^25" | bc -l))%"

if [[ -z "$DISCOUNT_RATE" ]]; then
    error_exit "DISCOUNT_RATE is not defined"
fi
echo "DISCOUNT_RATE = $(printf %.2f $(echo "(($DISCOUNT_RATE-10^27)*(60 * 60 * 24 * 365))/10^25" | bc -l))%"

if [[ -z "$MAX_RESERVE" ]]; then
    warning_msg "MAX_RESERVE is not defined"
fi
echo "MAX_RESERVE = $(printf %.0f $(echo "$MAX_RESERVE/10^18/10^3" | bc -l))k"

if [[ -z "$MAX_SENIOR_RATIO" ]]; then
    warning_msg "MAX_SENIOR_RATIO is not defined"
fi
echo "MAX_SENIOR_RATIO = $(printf %.2f $(echo "$MAX_SENIOR_RATIO/10^25" | bc -l))%"

if [[ -z "$MIN_SENIOR_RATIO" ]]; then
    warning_msg "MIN_SENIOR_RATIO is not defined"
fi
echo "MIN_SENIOR_RATIO = $(printf %.2f $(echo "$MIN_SENIOR_RATIO/10^25" | bc -l))%"

if [[ -z "$CHALLENGE_TIME" ]]; then
    warning_msg "CHALLENGE_TIME is not defined"
fi
echo "CHALLENGE_TIME = $(printf %.0f $(echo "$CHALLENGE_TIME/60" | bc -l)) min"

if [[ -z "$JUNIOR_TOKEN_NAME" ]]; then
    error_exit "JUNIOR_TOKEN_NAME is not defined"
fi
echo "JUNIOR_TOKEN_NAME = $JUNIOR_TOKEN_NAME"

if [[ -z "$JUNIOR_TOKEN_SYMBOL" ]]; then
    error_exit "JUNIOR_TOKEN_SYMBOL is not defined"
fi
echo "JUNIOR_TOKEN_SYMBOL = $JUNIOR_TOKEN_SYMBOL"

if [[ -z "$SENIOR_TOKEN_NAME" ]]; then
    error_exit "SENIOR_TOKEN_NAME is not defined"
fi
echo "SENIOR_TOKEN_NAME = $SENIOR_TOKEN_NAME"

if [[ -z "$SENIOR_TOKEN_SYMBOL" ]]; then
    error_exit "SENIOR_TOKEN_SYMBOL is not defined"
fi
echo "SENIOR_TOKEN_SYMBOL = $SENIOR_TOKEN_SYMBOL"

if [[ -z "$NAV_IMPLEMENTATION" ]]; then
    error_exit "NAV_IMPLEMENTATION is not defined"
fi
echo "NAV_IMPLEMENTATION = $NAV_IMPLEMENTATION"

# Admin Setup
message Admin Setup

if [[ -z "$POOL_ADMIN1" ]]; then
    error_exit "POOL_ADMIN1 is not defined"
fi
echo "POOL_ADMIN1 = $POOL_ADMIN1"

if [[ -z "$POOL_ADMIN2" ]]; then
    error_exit "POOL_ADMIN2 is not defined"
fi
echo "POOL_ADMIN2 = $POOL_ADMIN2"

if [[ -z "$POOL_ADMIN3" ]]; then
    error_exit "POOL_ADMIN3 is not defined"
fi
echo "POOL_ADMIN3 = $POOL_ADMIN3"

if [[ -z "$POOL_ADMIN4" ]]; then
    error_exit "POOL_ADMIN4 is not defined"
fi
echo "POOL_ADMIN4 = $POOL_ADMIN4"

if [[ -z "$POOL_ADMIN5" ]]; then
    error_exit "POOL_ADMIN5 is not defined"
fi
echo "POOL_ADMIN5 = $POOL_ADMIN5"

if [[ -z "$AO_POOL_ADMIN" ]]; then
    error_exit "AO_POOL_ADMIN is not defined"
fi
echo "AO_POOL_ADMIN = $AO_POOL_ADMIN"

if [[ -z "$ORACLE" ]]; then
    error_exit "ORACLE is not defined"
fi
echo "ORACLE = $ORACLE"

# Maker Setup
if [ "$IS_MKR" == "true" ]; then
    message Maker Setup

    if [[ -z "$MKR_MGR_FAB" ]]; then
        error_exit "MKR_MGR_FAB is not defined"
    fi
    echo "MKR_MGR_FAB = $MKR_MGR_FAB"

    if [[ -z "$MKR_DAI" ]]; then
        error_exit "MKR_DAI is not defined"
    fi
    echo "MKR_DAI = $MKR_DAI"

    if [[ -z "$MKR_DAI_JOIN" ]]; then
        error_exit "MKR_DAI_JOIN is not defined"
    fi
    echo "MKR_DAI_JOIN = $MKR_DAI_JOIN"

    if [[ -z "$MKR_SPOTTER" ]]; then
        error_exit "MKR_SPOTTER is not defined"
    fi
    echo "MKR_SPOTTER = $MKR_SPOTTER"

    if [[ -z "$MKR_VAT" ]]; then
        error_exit "MKR_VAT is not defined"
    fi
    echo "MKR_VAT = $MKR_VAT"

    if [[ -z "$MKR_JUG" ]]; then
        error_exit "MKR_JUG is not defined"
    fi
    echo "MKR_JUG = $MKR_JUG"

    if [[ -z "$MKR_LIQ" ]]; then
        error_exit "MKR_LIQ is not defined"
    fi
    echo "MKR_LIQ = $MKR_LIQ"

    if [[ -z "$MKR_END" ]]; then
        error_exit "MKR_END is not defined"
    fi
    echo "MKR_END = $MKR_END"

    if [[ -z "$MKR_MAT_BUFFER" ]]; then
        warning_msg "MKR_MAT_BUFFER is not defined"
    fi
    echo "MKR_MAT_BUFFER = $(printf %.2f $(echo "$MKR_MAT_BUFFER/10^25" | bc -l))%"
fi


if [[ -n "$ROOT_CONTRACT" ]]; then
    message Resuming deployment

    echo "ROOT_CONTRACT = $ROOT_CONTRACT"

    if [[ -n "$BORROWER_DEPLOYER" ]]; then
        echo "BORROWER_DEPLOYER = $BORROWER_DEPLOYER"
    fi

    if [[ -n "$LENDER_DEPLOYER" ]]; then
        echo "LENDER_DEPLOYER = $LENDER_DEPLOYER"
    fi
fi

printf "\n\n"