all    :; dapp build
clean  :; dapp clean
build  :; ./bin/util/build_contracts.sh
test-config  :; ./bin/test/setup_local_config.sh
deploy  :; ./bin/deploy.sh
test   :; dapp test
