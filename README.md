# Tinlake Deploy
Contains the scripts to deploy the [Tinlake contracts](https://github.com/centrifuge/tinlake]) to Ethereum mainnet or a testnet.


## Requirements
Tinlake is build and developed with  [dapp.tools](https://github.com/dapphub/dapptools) from DappHub.
The deployments happens with bash scripts and the command-line tool `seth`.



### Deploy Config File
For a deployment config file needs to be defined.
### Required Parameters
```json
{
  "ETH_RPC_URL": "<<RPC URL>>",
  "ETH_FROM": "<<ADDRESS>>",
  "TINLAKE_CURRENCY": "<<ADDRESS>>",
  "MAIN_DEPLOYER": "<<ADDRESS>>"
}
```
`TINLAKE_CURRENCY` defines the stablecoin for the Tinlake. For example on mainnet this could be the `DAI` stablecoin or any other ERC20 contract.
`MAIN_DEPLOYER` is a contract which deploys our factories with the create2 opcode.  The other parameters are default config parameters from `seth`


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
**1. Build contracts**
```json
./bin/util/build_contracts.sh
```

**2. Start your own local testnet. Run in a seperated terminal**
```bash
dapp testnet

```
**3. Generate Test Config File**
```bash
./bin/test/setup_local_config.sh 
```

**4. Run deploy script**
```bash
./bin/deploy.sh
```

### Util Scripts

**Create Main Deployer**
```json
dapp create MainDeployer 
```

## Customizable Modular Contracts
It is possible to customize a Tinlake deployment with modular contracts. The deploy script
uses the default version of each modular contract, if no specific contract is defined.

A modular contract can be specified in the `config` file. For the difference between the modular contracts
visit our documentation website.

### Assessor Contract

**Default Assessor**

Calculates senior interest bearing amount based on borrowed tranche currency amount.
```json
{
 "ASSESSOR": "default"
}
```
**Full Investment Assessor**

Calculates senior interest bearing amount based on investement currency in the senior tranche.
```json
{
 "ASSESSOR": "full_investment"
}
```
### Ceiling Contract

**Principal Ceiling**
```json
{
 "CEILING": "principal"
}
```
If not defined `principal` is the default Ceiling contract implementation.

**CreditLine Ceiling**
```json
{
 "CEILING": "creditline"
}
```
### Operator Contract

**Allowance Operator**
```json
{
 "OPERATOR": "allowance"
}
```
If not defined `allowance` is the default
**Whitelist Operator**
```json
{
 "OPERATOR": "whitelist"
}
```

**Whitelist Operator**

### Senior Tranche
```json
{
 "SENIOR_TRANCHE": "true"
}
```
If not defined the default is `false`.

If the senior tranche is `true` a senior operator must be defined.

```json
{
 "SENIOR_OPERATOR": "allowance"
}
```
The other option is `whitelist` by default the `allowance` contract is used. 
