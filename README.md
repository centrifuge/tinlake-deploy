# Tinlake Deploy

Contains the scripts to deploy the [Tinlake contracts](https://github.com/centrifuge/tinlake]) to Ethereum mainnet or a testnet.

## Requirements

1. Tinlake is build and developed with  [dapp.tools](https://github.com/dapphub/dapptools) from DappHub. The deployments happens with bash scripts and the command-line tool `seth`. ! note: dapp.tools version has to be > 0.28.0.
2. On MacOS, install coreutils `brew install coreutils` (this package cotains `realpath`, a dependency used in the scripts).
3. On Linux, install `jq`, e. g. with `apt-get install jq`
3. Init/update git submodules: `git submodule update`

### Deploy Config File

For a deployment config file needs to be defined.

### Required Parameters

```json
{

  "ETH_RPC_URL": "<<RPC URL>>",
  "ETH_FROM": "<<ADDRESS>>",
  "TINLAKE_CURRENCY": "<<ADDRESS>>",
  "MAIN_DEPLOYER": "<<ADDRESS>>",
  "SENIOR_INTEREST_RATE": "<<NUMBER>>",
  "MAX_RESERVE": "<<NUMBER>>",
  "MAX_SENIOR_RATIO": "<<NUMBER>>",
  "MIN_SENIOR_RATIO": "<<NUMBER>>",
  "CHALLENGE_TIME": "<<NUMBER>>",
  "DISCOUNT_RATE": "<<NUMBER>>",
  "FEED": "nav",
  "JUNIOR_TRANCHE_NAME":  "<<STRING>>",
  "JUNIOR_TRANCHE_SYMBOL":"<<STRING>>",
  "SENIOR_TRANCHE_NAME": "<<STRING>>",
  "SENIOR_TRANCHE_SYMBOL": "<<STRING>>",
}
```

`TINLAKE_CURRENCY` defines the stablecoin for the Tinlake. For example on mainnet this could be the `DAI` stablecoin or any other ERC20 contract.
`MAIN_DEPLOYER` is a contract which deploys our factories with the create2 opcode.  The other parameters are default config parameters from `seth`
`SENIOR_INTEREST_RATE`should follow ONE as 10^27 (ratePerSecond)
`MAX_RESERVE` should follow ONE as 10^18
`MAX_SENIOR_RATIO` should follow ONE as 10^27
`MIN_SENIOR_RATIO` should follow ONE as 10^27
`CHALLENGE_TIME` should be in seconds
`DISCOUNT_RATE` should follow ONE as 10^27
`SENIOR_TRANCHE_SYMBOL` string not longer then 6 chars
`SENIOR_TRANCHE_SYMBOL` string not longer then 6 chars

### NFT Feed

It is possible to use the NFT Feed or the NAV Feed

To use the NAV Feed, set FEED to nav

```json
{
 "FEED": "nav"
}
```
Otherwise, the FEED will default to the NFT Feed

### Optional Parameters

```json
{
  "ETH_GAS": "<<NUMBER>>",
  "ETH_GAS_PRICE": "<<NUMBER>>",
  "ETH_KEYSTORE": "<<DIR PATH>>",
  "ETH_PASSWORD": "<<FILE PATH>>",
}
```

The config file can contain addresses for Fabs.

## Deploy Contracts

### Build Contracts

```json
./bin/util/build_contracts.sh
```

### Deploy Contracts
For deploying the contracts execute the following script.

```bash
./bin/deploy.sh <<Optional: Path to config file>>
```
The default filepath of the configfile is: `./config_$(seth chain).json`
`seth chain` returns the name of the current chain based on the provided

## Local Test Deployment of Contracts

**1. Set env variables**

Adjust `.env-example.sh`, and run `source env-example.sh`.

**2. Build contracts**

```json
./bin/util/build_contracts.sh
```

**3. Start your own local testnet. Run in a seperated terminal**

```bash
dapp testnet
```

**4. Generate Test Config File**

```bash
./bin/test/setup_local_config.sh
```

This should generate a file at `./bin/config_unknown.json`. Modify that file if needed.

**5. Run deploy script**

```bash
./bin/deploy.sh
```

## Docker-based Test Deployment of Contracts

**1. Build the docker image**

```bash
docker build -t centrifugeio/tinlake-deploy:latest .
```

**2. Run a docker container**

```bash
docker run --rm -p 8545:8545 centrifugeio/tinlake-deploy:latest
```

## Util Scripts

**Create Main Deployer**
```json
dapp create MainDeployer
```
