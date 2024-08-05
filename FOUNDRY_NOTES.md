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
function testDeposit2(uint256 amount) public {
    vm.assume(amount > 0); // When 0 is passed as a value, it will not pass through this cheatcode, and will go to the next fuzz run with a different value
    vm.assume(amount < address(this).balance);
    // ...
}
```  
  
5. Code your tests using the Hoare logic (preconditions, then actions, then postconditions)  
```javascript
function addLiquidity(uint amount1, uint amount2) public {
    // PRECONDITIONS
    amount1 = clampBetween(...);
    amount2 = clampBetween(...);

    // ACTIONS
    bool success = _addLiquidity(amount1, amount2);

    // POSTCONDITIONS
    if(succes) {
        // ...
    }
}
```  
  
6. Can take about a week to set up your invariant tests. Take a day to figure out all the invariants to test. Second day to set up your environment, foundry invariant tests, etc. You have three days to kind of fine-tune your tests, think about all the scenarios you want to test. Takes time to set it up if a lot of external libraries used.  
  
7. Use ghost variables to check "before/after"  
```javascript
function deposit(uint256 assets) public virtual {
    asset.mint(address(this), assets);

    asset.approve(address(token), assets);

    uint256 shares = token.deposit(asset, address(this));
    // sumBalanceOf is a ghost variable which can be later checked against token contract's total shares
    sumBalanceOf += shares;
}
```  
  
8. Check logic against different/deoptimized implementations  
```javascript
function invariant_totalDebtEqualsSum() internal view returns (bool) {
    uint256 totalDebt = vault.totalDebt();
    uint256 sum = 0;
    for(uint i = 0; i<positions.length; i++) {
      sum += positions.getDebt();
    }

    return sum == totalDebt;
}
```

9. Use multiple actors for more realistic scenarios  
```javascript
modifier useActor(uint256 actorIndexSeed) {
    currentActor = actors[bound(actorIndexSeed, 0, actors.length-1);
    // If your protocol has many roles/actors, you can set up a modifier like this one and randomly choose an actor for testing
    vm.startPrank(currentActor);
    _;
    vm.stopPrank();
}
```  
  
10. Limit the number of targets and selectors the fuzzer is calling (including state vars). In case of Foundry, make sure to manually select the selectors you want to test and in case of Echidna, make sure your state vars are `internal` as it will try to fuzz the public state vars and waste time as they are read-only.  
  
11. Check both success and failure cases for max coverage with either `try catch` or `if else`. Echidna case -  
```javascript
if(success) {
    gt(
        vars.kAfter,
        vars.kBefore,
        "P-01 | Adding Liquidity increases K"
    );
    // ...
} else {
    eq(
        vars.kAfter,
        vars.kBefore,
        "P-08 | Adding liquidity should not change anything if it fails"
    );
    // ...
}
```  
  
12. Think about how your invariants may change depending on the state of the system.  
    
13. Always check the code coverage. In Echidna, you can see the coverage with a coverage report, which is an HTML file in which you can see the parts that have been covered with tests. Shows green for parts covered, yellow for parts that haven't been covered properly and red means parts that have not been covered at all.  
  
14. Reduce the input space of the fuzzer  

## **Foundry Commands**  
  
- ### `forge test`  
  - `--match-test` for specifying a test function. `-m` is deprecated.  
  - `--match-path` for specifying the path of the test contract.  
  - `--fork-url` for forking any network.  
  
- ### `forge snapshot`
  - Creates a file (`.gas-snapshot`) with the gas costs of the test  
  - Use with same commands as for `forge test`  
  
## **Foundry Cheatcodes**  
  
- `vm.expectRevert(...)` is used when the next LoC is supposed to revert. If not, the test fails.  
- `vm.prank(address)` sets the provided address as the msg.sender for the next call.  
- `makeAddr(string)` takes a name as a string and generates an address for the same name.  
- `vm.deal(address, uint256)` takes an address and gives it an amount of tokens  
- `hoax(address, uint256)` combination of `vm.prank()` and `vm.deal()`  
- `vm.txGasPrice(uint256)` sets the tx.gasprice() for the rest of the transaction  
  
## **Random Notes**  

`forge fmt` to format your code  
  
Gas costs can be calculated by taking gas used in testnet, multiply by latest gas price on mainnet and convert to USD. Visible that Eth mainnet is very expensive so prefer to deploy on an L2 chain like zkSync.  
forge -> Compiling and interacting with contracts  
cast -> Interacting with contracts that have already been deployed  
anvil -> To deploy a local blockchain  
chisel -> To type and run small snippets of solidity in terminal, maybe for checking something or testing  
`address` cannot be explicitly cast as `uint256`. It needs to be cast as `uint160` and then as `uint256`.  
```javascript
address a = msg.sender;
return uint256(uint160(a));
```  
When deploying with anvil and using it, the gas price defaults to 0.  
