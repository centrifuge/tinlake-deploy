#! /usr/bin/env bash

# remove $GOVERNANCE user from permissions (for mainnet deployments)
# root contract to be set as multisig

BIN_DIR=${BIN_DIR:-$(cd "${0%/*}"&&pwd)}
source $BIN_DIR/util.sh

cd $BIN_DIR
ADDRESSES="./../../deployments/addresses_$(seth chain).json"

loadValuesFromFile $ADDRESSES

message Denying Governance Address: $GOVERNANCE

message Title
seth send $ROOT_CONTRACT 'denyContract(address,address)' $TITLE $GOVERNANCE

message Pile
seth send $ROOT_CONTRACT 'denyContract(address,address)' $PILE $GOVERNANCE

message Shelf
seth send $ROOT_CONTRACT 'denyContract(address,address)' $SHELF  $GOVERNANCE

message Collector
seth send $ROOT_CONTRACT 'denyContract(address,address)' $COLLECTOR  $GOVERNANCE

message Feed
seth send $ROOT_CONTRACT 'denyContract(address,address)' $FEED  $GOVERNANCE

message Junior Operator
seth send $ROOT_CONTRACT 'denyContract(address,address)' $JUNIOR_OPERATOR $GOVERNANCE

message Senior Operator
seth send $ROOT_CONTRACT 'denyContract(address,address)' $SENIOR_OPERATOR $GOVERNANCE

message Junior Tranche
seth send $ROOT_CONTRACT 'denyContract(address,address)' $JUNIOR_TRANCHE $GOVERNANCE

message Senior Tranche
seth send $ROOT_CONTRACT 'denyContract(address,address)' $SENIOR_TRANCHE  $GOVERNANCE

message Junior Token
seth send $ROOT_CONTRACT 'denyContract(address,address)' $JUNIOR_TOKEN  $GOVERNANCE
message Senior Token
seth send $ROOT_CONTRACT 'denyContract(address,address)' $SENIOR_TOKEN  $GOVERNANCE

message Junior Memberlist
seth send $ROOT_CONTRACT 'denyContract(address,address)' $JUNIOR_MEMBERLIST  $GOVERNANCE
message Senior Memberlist
seth send $ROOT_CONTRACT 'denyContract(address,address)' $SENIOR_MEMBERLIST $GOVERNANCE

message Assessor
seth send $ROOT_CONTRACT 'denyContract(address,address)' $ASSESSOR $GOVERNANCE

message Epoch Coordinator
seth send $ROOT_CONTRACT 'denyContract(address,address)' $COORDINATOR $GOVERNANCE

message Reserve
seth send $ROOT_CONTRACT 'denyContract(address,address)' $RESERVE  $GOVERNANCE

message Root Contract
seth send $ROOT_CONTRACT 'deny(address)' $GOVERNANCE
