#! /usr/bin/env bash
dapp testnet &
make build
make test-config
make deploy
