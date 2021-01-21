all    :; dapp build
clean  :; dapp clean
build  :; ./bin/util/build_contracts.sh
test   :; dapp test
deploy :; dapp create TinlakeDeploy
