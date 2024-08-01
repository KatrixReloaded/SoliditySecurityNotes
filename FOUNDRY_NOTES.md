# Foundry Notes  
  
## **Deploying with Anvil**  
  
Simulation ->  
```git
forge script script/DeployContract.sol --rpc-url <ANVIL CHAIN URL>
```
  
Actual deployment on local chain ->  
```git
forge script script/DeployContract.sol --rpc-url <LOCAL CHAIN URL> --broadcast <PRIVATE KEY from ANVIL CHAIN>
```  
    
## Importing from GitHub  
  
To import a library from GitHub, we need to run the following command: 
```bash
forge install <OWNER-NAME>/<REPO-NAME>@<VERSION> --no-commit
# For example
forge install smartcontractkit/chainlink-brownie-contracts@1.1.1 --no-commit
```
  
## **Encrypting Private Key**  
  
Run `cast wallet import -i <name>` or `cast wallet import <name> --interactive`.  
Paste the private key into the prompt.  
Set a strong password at least 20 chars long so that it can't be brute-forced.  
Use the account and sender flag when running Foundry commands like this: `forge script <script_location>:<contract_name> --rpc-url <rpc_url> --account <name> --sender <public_key> --broadcast`.   
If actually deploying to, for example, Sepolia, we would also add `--verify --etherscan-api-key`.  
Type `cast wallet list` to check the list of wallets.  
(Can also go to home directory, then `cd ./foundry/keystores/`, then `ls` to see list of keystores.)  
Then type `cat <wallet_name>` to see the encrypted version of the private key which follows ERC-2335.  
  
## **Call and send with Command-line**  
  
Run `cast send <Contract_Address> "<fn. sign>" args --rpc-url <RPC_URL> --private-key <PRIVATE_KEY>` to send values to a function as parameters. Sending transaction.   
`cast call` has the same arguments as above but it is used for calling a function where a value is returned. Calling transaction.  
`cast --to-base <HEX_VALUE> dec` to convert hex values to decimal values.  

## **zkSync**  
  
### Setup  
foundry-zksync installed.  
To switch back to vanilla Foundry, simply run `foundryup`, and to switch back to foundry-zksync, run `foundryup-zksync`  
Run `forge build --zksync` to compile with zkSync  
  
## Invariant Testing  
  
1. Go through the documentation and look for invariants before even looking at the code
2. Categorize your invariants based on their properties
3. Write invariants in order of priority
4. Bound values to not waste fuzz runs
  
```javascript
// GOOD
function testDeposit1(uint256 amount) public {
    amount = bound(amount, 0, address(this).balance);
    // ...
}

// BAD
function testDeposit1(uint256 amount) public {
    vm.assume(amount > 0); // When 0 is passed as a value, it will not pass through this cheatcode, and will go to the next fuzz run with a different value
    vm.assume(amount < address(this).balance);
    // ...
}
```
  
## **Random Notes**  

`forge fmt` to format your code  
  
Gas costs can be calculated by taking gas used in testnet, multiply by latest gas price on mainnet and convert to USD. Visible that Eth mainnet is very expensive so prefer to deploy on and L2 chain like zkSync.  
forge -> Compiling and interacting with contracts  
cast -> Interacting with contracts that have already been deployed  
anvil -> To deploy a local blockchain
