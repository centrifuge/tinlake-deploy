#! /usr/bin/env bash

# give $ADMIN user necessary permissions
# set $ADMIN address before running this script

BIN_DIR=${BIN_DIR:-$(cd "${0%/*}"&&pwd)}
source $BIN_DIR/util.sh

cd $BIN_DIR
ADDRESSES="./../../deployments/addresses_$(seth chain).json"

loadValuesFromFile $ADDRESSES

message Relying Admin Address: $ADMIN

message Junior Operator
seth send $ROOT_CONTRACT 'relyContract(address,address)' $JUNIOR_OPERATOR $ADMIN
message Senior Operator
seth send $ROOT_CONTRACT 'relyContract(address,address)' $SENIOR_OPERATOR $ADMIN
message Feed
seth send $ROOT_CONTRACT 'relyContract(address,address)' $FEED $ADMIN
message Assessor
seth send $ROOT_CONTRACT 'relyContract(address,address)' $ASSESSOR $ADMIN
message Junior Memberlist
seth send $ROOT_CONTRACT 'relyContract(address,address)' $JUNIOR_MEMBERLIST $ADMIN
message Senior Memberlist
seth send $ROOT_CONTRACT 'relyContract(address,address)' $SENIOR_MEMBERLIST $ADMIN
message Root Contract
seth send $ROOT_CONTRACT 'rely(address)' $ADMIN
message Epoch Coordinator
seth send $ROOT_CONTRACT 'relyContract(address,address)' $COORDINATOR $ADMIN
message Pile
seth send $ROOT_CONTRACT 'relyContract(address,address)' $PILE $ADMIN
