# Smart Contract Security Notes  
**Contents**  
----------
- [Smart Contract Security Notes](#smart-contract-security-notes)
  - [**Contents**](#contents)
  - [**Transactions - Function call**](#transactions---function-call)
  - [**Transactions - Contract Deployment**](#transactions---contract-deployment)
  - [**Rough approximation of audit duration**](#rough-approximation-of-audit-duration)
  - [**Tools for auditing**](#tools-for-auditing)
  - [**Note-taking methodology**](#note-taking-methodology)
  - [**Findings**](#findings)
  - [**Scoping process**](#scoping-process)
  - [**Reading a private variable in a smart contract**](#reading-a-private-variable-in-a-smart-contract)
  - [**Reentrancy Soln.**](#reentrancy-soln)
  - [**Weak Randomness**](#weak-randomness)
  - [**Integer overflow and underflow**](#integer-overflow-and-underflow)
  - [**Self Destruct**](#self-destruct)
  - [**Transaction Displacement Attacks**](#transaction-displacement-attacks)
  - [**Invariants**](#invariants)
    - [Two types of invariants:](#two-types-of-invariants)
  - [**Weird ERC20s**](#weird-erc20s)
  - [**Tincho Method**](#tincho-method)
  - [**Invariant Testing**](#invariant-testing)
  - [**Echidna**](#echidna)
  - [**Decoding function calls in MetaMask**](#decoding-function-calls-in-metamask)
  - [**Generating a random number (Chainlink VRF)**](#generating-a-random-number-chainlink-vrf)
  - [**Chainlink Automation (Keepers)**](#chainlink-automation-keepers)
  - [**Notes from Cergyk.eth**](#notes-from-cergyketh)
    - [Threat Modelling](#threat-modelling)
    - [Questions](#questions)
    - [Introduce Complexity](#introduce-complexity)
    - [Steelman Ideas](#steelman-ideas)
  - [**How to NOT miss vulnerabilities**](#how-to-not-miss-vulnerabilities)
  - [**Some additional bugs**](#some-additional-bugs)
  - [**HTLC**](#htlc)
  - [**Formal Verification**](#formal-verification)
    - [**Halmos**](#halmos)
    - [**Certora**](#certora)
  - [**Random Notes**](#random-notes)
  - [**Useful Links**](#useful-links)
  - [**References**](#references)
  - [**Questions**](#questions-1)
  
  
  
  
**Transactions - Function call**  
----------
1. Nonce: tx count for the account  
2. Gas Price: price per unit of gas(in wei)  
3. Gas Limit: max gas that this tx can use  
4. To: address that the tx is sent to  
5. Value: amount of wei to send  
6. Data: what to send to the To address  
7. v,r,s: components of tx signature  
  
**Transactions - Contract Deployment**  
----------
1. Nonce: tx count for the account  
2. Gas Price: price per unit of gas(in wei)  
3. Gas Limit: max gas that this tx can use  
4. To: empty  
5. Value: amount of wei to send  
6. Data: contract init code & contract bytecode  
7. v,r,s: components of tx signature  
  
>We can send the data field of the tx ourselves with our function call hexcode  
>call: how we call functions to change the state of the blockchain  
>staticcall: this is how (at a low level) we do our "view" or "pure" function calls, and potentially don't change the blockchain  
  
```javascript
tx = {  
    nonce: nonce,  
    gasPrice: 100000000,  
    gasLimit: 100000,  
    to: null,  
    value: 0,  
    data: "0x608060...0f0345", //EVM level data, low level  
    chainId: 1337,  
} 
``` 
  
>For example-  
>(bool success, ) = recentWinner.call{value: address(this).balance}("");  
>Here, we change the value (Line 5) field of a transaction directly, the parantheses at the end is where we put the data (Line 6)  
>In our {} we are able to pass specific fields of a transaction, like value  
>In our () we are able to pass data in order to call a specific function but there was no function we wanted to call in Line 34.  
  
selfdestruct is a keyword in solidity that is used to delete/destroy a contract.  
Proxies can be used to make changes to a smart contract. Kinda negates the "decentralization" part of blockchain. Leads to rag-pulling.  
  
  
  
  
**Rough approximation of audit duration**  
----------
>LoC : Duration -   
>100 : 2.5 days  
>500 : 1 week  
>1000 : 1-2 weeks  
>2500 : 2-3 weeks  
>5000 : 3-5 weeks  
>5000+ : 5+ weeks  
  
Findings are listed by severity in a report - Highs, Mediums, Lows, Informational, Gas efficiencies and non-critical (Last 3 are not vulnerabilities, but ways to improve code).  
  
  
Tests to see if a protocol is ready for auditing:  
GitHub repo -> [1]  
The Rekt Test  
  
  
  
  
**Tools for auditing**  
----------
>Test Suites:  
>Hardhat, Foundry, Brownie, etc.  
          
>Static Analysis:  
>Slither, Aderyn, Mythril  
  
>Fuzzing:  
>Foundry, Echidna  
  
>Formal Verification:  
>Symbolic Execution - MAAT, Z3, Manticore  
  
Machine-findable bugs and non-machine-findable bugs - [2]  
Resource for building secure contracts - [10]
  
  
  
  
**Note-taking methodology**  
----------
>Bug: //!  
>For my information: //i  
>Questions: //q  
>Potential issue: //@audit  
>Explanation: //e  
>Make sure to follow up: //@follow-up  
>Informational audit note: //@audit-info  
>Code location for a filed issue: //@audit-issue  
>Not an issue, even if it looks like one: //@audit-ok  
>Notes: //@note  
>Todo remark: //@todo  
>Reminder: //@remind  
  
Look for questions after scoping and figure out answers  
Check code coverage with "forge coverage"  
  
  
  
  
**Findings**  
----------
>1. Convince the protocol this is an issue  
>2. How bad this issue is  
>3. How to fix the issue  
  
Layouts and notes on reports - [3]  
Severity Guide - [4]  
  
  
  
  
**Scoping process**  
----------
Refer to minimal-onboarding in `[3]`  
Check branch  
```git
git branch
```  
Check the commit hash of the scope and then type
```git
git checkout <COMMIT HASH HERE>  
```  
Switch to a new branch
```git
git switch -c NewProject-audit   
```  
  
  
  
  
**Reading a private variable in a smart contract**  
---------
>1. Create a locally running chain  
>```bash
>make anvil
>```
>  
>2. Deploy the contract to the chain   
>```
>make deploy
>```
>
>3. Run the storage tool  
>We use `1` because that's the storage slot of `PasswordStore::s_password` in the contract.  
>```
>cast storage <ADDRESS HERE> 1 --rpc-url http://127.0.0.1:8545
>```
>
>You'll get an output that looks like this:
>`0x6d7950617373776f726400000000000000000000000000000000000000000014`
>
>You can then parse that hex to a string with:
>```
>cast parse-bytes32-string 0x6d7950617373776f726400000000000000000000000000000000000000000014
>```
>
>And get an output of:
>```
>myPassword
>```
  
  
  
  
**Reentrancy Soln.**  
----------  
```javascript
bool locked = false;
//locked is set to see if the function has been entered once, if yes, then revert if tried to reenter
function withdrawBalance() public {
    if(locked) revert();
    locked = true;

    uint256 balance = userBalance[msg.sender];
    userBalance[msg.sender] = 0;

    (bool success, ) = msg.sender.call{value: balance}("");
    if(!success) {
        revert();
    }

    locked = false;
}
```  
Can use OpenZeppelin's `ReentrancyGuard.sol::nonReentrant()` [5] which essentially does the same thing under the hood.   
A Historical Collection of Reentrancy Attacks -> [6]  
  
  
  
  
**Weak Randomness**  
------  
  
```javascript
uint256 winnerIndex = uint256(keccak256(abi.encodePacked(msg.sender, block.timestamp, block.difficulty))) % players.length;
```  
The values used to create a pseudo-random number can be manipulated or predicted and can be used to get the random number.  
fixes: Chainlink VRF, Commit Reveal Scheme
  
  
  
  
**Integer overflow and underflow**  
--------  
Use `chisel` in cmd and then `type(<DATATYPE>).max` to check the maximum value of a datatype. Comes with foundry.  
> Note: `int` max value is 2^255(as the first bit is reserved for the sign, aka, the sign bit) whereas `uint` max value is 2^256-1. This may lead to an overflow in 0.7.x or lower and an exception in 0.8+.  
  
  
  
  
**Self Destruct**  
---------  
If a contract doesn't have a `receive` or `fallback` function, it reverts any attempts to send it any value but an attackerSelfDestruct contract can self-destruct and force the contract to accept the money. This will cause the `address(this).balance == totalBalance` check to fail.  
  
Check this smart contract for an example - [7]  
  
  
  
  
**Transaction Displacement Attacks**  
----------  
  
An attacker replaces a legitimate transaction with their own, to steal something of value intended for the legitimate transaction's sender.  
Examples - 
- Alice tries to register a domain name but Mallory does it first  
- Alice tries to submit a bug but Mallory steals it and submits it first  
- Alice tries to submit a bid in an auction and Mallory is copying it  
  
  
  
  
**Invariants**  
--------  
Invariants in ERC20 and ERC721 - [7]  
**1. Stateless Fuzzing - Open**  
>Stateless fuzzing (often known as just "fuzzing") is when you provide random data to a function to get some invariant or property to break.  
>  
>It is "stateless" because after every fuzz run, it resets the state, or it starts over.   
  
**2. Stateful Fuzzing - Open**  
>Stateful fuzzing is when you provide random data to your system, and for 1 fuzz run your system starts from the resulting state of the previous input data.  
>
>Or more simply, you keep doing random stuff to the same contract.  
  
**3. Stateful Fuzzing - Handler**  
>Handler based stateful fuzzing is the same as Open stateful fuzzing, except we restrict the number of "random" things we can do.  
>
>If we have too many options, we may never randomly come across something that will actually break our invariant. So we restrict our random inputs to a set of specfic random actions that can be called.  
  
**4. Formal Verification**  
>Formal verification is the process of mathematically proving that a program does a specific thing, or proving it doesn't do a specific thing.  
>
>For invariants, it would be great to prove our programs always exert our invariant.  
>
>One of the most popular ways to do Formal Verification is through Symbolic Execution. Symbolic Execution is a means of analyzing a program to determine what inputs cause each part of a program to execute. It will convert the program to a symbolic expression (hence its name) to figure this out.  
  
**foundry.toml ->**  
```
[fuzz]
runs = 256
seed = '0x2'

[invariant]
runs = 64
depth = 32
fail_on_revert = false
```  
`seed` helps input the randomness. Different seed == different random runs.  
`fail_on_revert = false` implies that we only care about the invariant breaking and no other reverts matter. Other reverts executed if set to true.  
  
### Two types of invariants:
  1. **Function-level invariants:**
  - Doesn't rely on much of the system OR could be stateless  
  - Can be tested in an isolated fashion  
  - Examples: Associative property of addition OR depositing tokens in a contract  
  2. **System-level invariants:**
  - Relies on the deployment of a large part or entire system  
  - Invariants are usually stateful  
  - Examples: user's balance < total supply OR yield is monotonically increasing  
  
  
  
  
**Weird ERC20s**  
--------
  
It is very important to know what tokens one protocol is working with in order to check for weird ERC20 tokens. They can break our contract with their strange states/rules.  
  
Weird ERC20 list - [9]  
  
  
  
  
**Tincho Method**  
--------  
  
After you are done running your automated tools(Slither, Aderyn, etc.), copy down all the in-scope contracts' details (nSLOC, complexity score, etc.) from the Solidity Metrics report and paste it in an Excel sheet. Then sort the sheet in order of ascending complexity score or nSLOC and go through each of them from lowest to highest.  
  
  
  
  
**Invariant Testing**  
--------  
  
1. Go through the documentation and look for invariants before even looking at the code  
  
2. Categorize your invariants based on their properties  
  
3. Write invariants in order of priority. Write your invariants in English, and then write them in Solidity.  
  
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
  
  
  
  
**Echidna**  
----------
  
- Needs the `echidna_` prefix for every function identifier for Echidna to be able to realize its inputs. (PROPERTY TESTING)  
- `echidna <test_file_name> --contract <test_contract_name>` for running Echidna.  
- Declare a test function without the echidna prefix, can use `test_`prefix instead(not necessary), write code for asserting a condition, and run echidna with the following input at the end: `--test-mode assertion`. This allows you to add parameters to the test as well. (ASSERTION TESTING) [11]  
- Testing system-level invariants require initialization  
  - **Simple initialization**  
    - Deploy everything in the constructor  
  - **Complex initialization**  
    - Leverage your unit tests framework with etheno `//q what is etheno?`  
  - **NOTE: Function-level invariants may also need some system initialization**  
  
- Medusa can be used for a more detailed fuzz test  
  - `medusa init` is the first command, generates a .json file which can be modified based on our requirements and to avoid using flags in the cmd  
    - In `medusa.json`, `targetContracts` sets the contract containing the test functions for fuzzing  
    - `assertionTesting` section should have `enabled` set to `true` for assertion testing and `enabled` set to `false` for `propertyTesting`, and vice-versa for property testing  
  - `medusa fuzz` is the command to run the test  
  
- Echidna has its own set of cheatcodes in `hevm`  
  - They are almost the same as the cheatcodes in Foundry  
  
- Structuring a function-level invariant  
  - Pre-condition checks  
    - Barriers of entry for the fuzzer. You can tell the fuzzer not to check these values if these conditions are not true  
    - Eg: `require(usdc.balanceOf(msg.sender) > 0)`  
  - Action  
    - What you are testing  
    - Eg: `usdc.transfer(to, amount)`  
  - Post-condition checks  
    - These are the "truths" you are testing  
    - Test both happy and not-so-happy paths (try/catch)  
    - Eg: `usdc.balanceOf(msg.sender) == initialBalance - amount`  
  
- Optimizing fuzzer performance  
  - Pre-conditions  
  - Arithmetic manipulation: Eg- `if(abs(x) == abs(y)) { y = x + 1; }`  
  - Modular arithmetic  
  
- Resources for understanding precision loss  
  - [A fixed point introduction by example](https://www.dsprelated.com/showarticle/139.php)  
  - [Binary Integer Fixed-point Numbers](https://www.dsprelated.com/freebooks/mdft/Binary_Integer_Fixed_Point_Numbers.html)  
  - [Fixed Point exponentiation](https://www.dsprelated.com/thread/8959/fixed-point-exponentiation)  
  - [On the Implementation of Fixed-point Exponential Function for Machine Learning and Signal Processing Accelerators](http://arxiv.org/pdf/2112.02263)  
  - [Fixed Point Math library for MSP Processors](https://www.ti.com/tool/MSP-IQMATHLIB)  
  
- External testing vs internal testing  
  - What is internal testing? Basically, when we inherit a particular contract that we need to fuzz and directly inherit all the instances.  
  - In external testing, we make external calls to the contract that we need to fuzz but the msg.sender is not preserved.  
  
- Reading a coverage report  
  - Each line in the coverage report is marked with:  
    - * - means execution ended with a STOP, no errors  
    - r - means execution ended with a REVERT  
    - o - means out-of-gas error  
    - e - means any other error, like zero division  
    - or none of the above - this means that the particular line was not covered  
  - In the `config.yaml` file always specify `corpusDir: corpus` in order to track coverage  
- Adding try catch blocks to check both the happy and not-so-happy paths allow you to cover every scenario and also see if tests fail during an external call, otherwise the assert line may not be reached.  
- AMM Fuzzing  
  - Swap Invariants:  
    - Swapping 0 tokens should net you 0 tokens out  
    - Swapping increases and decreases token balances accordingly  
    - Swapping x of token A for y of token B and back should get you x of token A  
    - Pool invariant should remain constant during swaps  
  - Core:  
    - contains the core logic of the AMM and the swaps  
  - Periphery:  
    - Set of contracts that interact with core  
    - Provide safety checks and helper functions  
    - Library: mainly contains helper functions  
      - Sort tokens, calculate amount in/out  
      - Can calculate amounts in/out for chained swaps  
    - Router: "routes" trades  
      - Provides safety checks for minimal core contracts  
      - In charge of transferring tokens properly  
      - If you've done a swap/provided liquidity before, you went through the router  
  
  
  
  
**Decoding function calls in MetaMask**  
----------  
  
Before approving/confirming a transaction on MetaMask, check the data section and the hex section, run `cast sig <function-sig>` to check the desired hex, and if it doesn't match, might be a malicious call.  
If there are parameters passed, run `cast --calldata-decode <function-sig> <calldata/hex value>` and it will tell you what parameters were passed.  
  
  
  
  
**Generating a random number (Chainlink VRF)**  
----------  
  
1st step: `docs.chain.link/vrf`  
2nd step: Create a subscription in subscription manager  
3rd step: Create a fund the subscription  
4th step: Use the subscription ID while deploying the contract  
5th step: Add a consumer contract to use the random number by giving the deployed contract address  
Check [12] for sample code using Chainlink VRF and natspec  
You need to mention how and where you are using the RNG in your contract and use it in the `fulfillRandomWords` function  
  
  
  
  
**Chainlink Automation (Keepers)**  
----------  
  
1st step: `docs.chain.link/chainlink-automation`  
2nd step: You will mostly be using a custom-based upkeep, so register one  
3rd step: There are two functions that Chainlink needs to automate your code: `checkUpkeep()` and `performUpkeep()`. Add those functions    
4th step: `checkUpkeep() returns(bool upkeepNeeded,)` checks the conditions required for the next automated call and if they are met, it will call `performUpkeep()`.  
Check [12] for sample code using Chainlink Automation and natspec
  
  
  
  
**Notes from Cergyk.eth**  
----------  
  
### Threat Modelling  
- What actors interact?  
- Which roles can I impersonate to impact what others?  
  
### Questions  
- Follow up a trail of questions  
  - What prevents me from just withdrawing everything?  
  - What about underlying state changes?  
- Gather new, more focused questions by following the trail  
- Repeat!  
  
### Introduce Complexity  
- Unfrequent actions  
- Sequence of actions that could break the protocol  
- Interoperability with external protocols  
- Collusion of multiple actors  
  
### Steelman Ideas  
- Confirm your mental models/ideas by playing with tests  
- Make sure dev missed something  
  - Identify wrong assumptions  
  - Make sure the exploit has reasonable complexity according to codebase  
- Knowing the stack and language  
  - Helps to model attack paths correctly  
  - Reduce false positives  
  
  
  
  
**Notes from Milotruck**  
----------  
- **First Phase: Preparation**  
  - Before the audit starts, prepare by doing recon. Look for docs, don't go in blind.  
  - Get an idea of what you'll be auditing and catch up on missing knowledge. For example, if there's an AMM, read up on topics related to it, like Uniswap V3 Math, etc.  
  - Look through Solodit for audits of similar protocols  
  - Get an idea of what bugs to look for:  
    - Bridges/cross-chain: Gas  
    - Lending: Loan manipulation  
- **Second Phase: Understanding**  
  - After the audit starts  
  - Answer the "What"s:  
    - What components exist in the system?  
    - What are the different actors and roles?  
    - What areas have the most complexity?  
  - Avoid the "How"s:  
    - Explanation of logic  
    - Specific details of the code  
  - Approaching the codebase  
    - Following the flow  
    - 

  
  
  
  
**How to NOT miss vulnerabilities**  
----------  
  
- Collaboration helps  
- Don't skip external calls in functions  
- Be skeptical, don't trust the devs and be like, "he's so good, can't make mistakes bruh"  
- Pls do write test cases  
- Download the fkin contracts in your brain  
- Always check for receive/fallback functions  
- Always check if parallel state variables are in sync  
- Write down notes, in-code comments  
- If you can create a diagram of how functions/contracts interact with each other, do it  
- Ask the devs questions  
- Don't examine each contract in isolation  
- Look at test coverage  
- Write PoCs  
- Have an attacker's mindset, not a dev's  
- Eat/sleep well lol  
  
  
  
  
**Some additional bugs**  
--------
- If you delete a struct that contains a list or a mapping, it does not recursively delete the list or mapping.  
```javascript
struct Object {
    mapping(uint256 => uint256) idToId;
}
mapping(uint256 => Object) objects;

function createObj(uint256 x, uint256 y, uint256 z) public {
    objects[x].idToId[y] = z;
}

function readObj(uint256 x, uint256 y) public view returns(uint256) {
    return objects[x].idToId[y];
}

function deleteObj(uint256 x) public {
    delete objects[x];
}
```
In this case, if I delete x and then call readObj again, I'll still see the value z, as it does not delete the mapping idToId.  
- In upgradeable contracts, the immutable variables are not migrated to the upgraded contract since they are not in storage.  
- MSTORE does not update the free memory pointer. If you have a normal Solidity code after an assembly block that uses MSTORE, most likely, the Solidity code is overwriting whatever was stored using MSTORE.  
- Be wary of precision loss and division by 0 whenever division is used.  
> #### **Note:** If a function executes a transfer, and then reverts afterwards due to some other condition or scenario, the entire state of the contract reverts. Meaning that the transfer is also reverted.  
  
  
  
  
**HTLC**  
----------
- **MAD-HTLC**: Mutual-Assured-Destruction Hashed Time-Locked Contract  
  - Crazy shit, you make both parties deposit the swap amount AND a collateral. If any malicious activity is detected from either parties, the miner penalizes both parties by taking both of their's deposits(including collateral).  
  - Miner has a huge incentive here, not recommended since miner can do a Reverse Bribery Attack(RBA).  
- **RBA**: Reverse Bribery Attack  
  - Success-Independent RBA: Miner is incentivized to bribe the creator of an order in HTLC with an amount greater than or equal to the user's deposited amount in exchange for the secret pre-image.  
  - Success-Dependent RBA: Miner reverse-bribes Bob in exchange for a confirmed on-chain tx confiscating the assets using the pre-image.  
  - Hybrid Delay RBA: Miner reverse-bribes Bob in exchange for a confirmed on-chain tx confiscating the deposits AND the collateral using the pre-image after the timeout.  
- **Bitcoin Core Transaction-Relay Vulnerability**:  
  - Basically, it can disrupt the transaction process on the Bitcoin network. Specifically, it allows for transaction-relay jamming, an off-chain protocol attack.  
  - It can flood the network with transaction traffic that can alter the outcome of an HTLC, preventing the propagation of specific Lightning channel transactions.  
  - By initiating a flood of transaction traffic, an attacker can effectively jam transaction relays. This jamming disrupts the normal transaction processing flow, leading to potential changes in contract outcomes, such as the HTLCs.  
- **He-HTLC**: Helium HTLC  
  - It's called that because it is light-weight and inert to all HTLC attacks.  
  
  
  
  
**Formal Verification**  
----------  
- Breaking a property using mathematical proofs  
- Convert code into mathematical expressions, dump the math into an SMT Solver like Z3  
- Solidity compiler can act as a symbolic execution tool  
  - `solc --model-checker-engine chc --model-checker-targets overflow XYZ.sol` would check the contract XYZ for any overflows  
  - Similarly, if I changed the `overflow` to an `assert`, it would check if any assertions are being violated  
- Manticore and Certora are tools for Symbolic Execution  
  
### **Halmos**  
- Setup is a lot similar to fuzz tests  
- Can use Halmos cheatcodes to set up symbolic arguments -> [13]  
- You can also call the constructor with symbolic arguments  
- Need to understand all cheatcodes, go through all examples on halmos/examples dir  
- Doesn't use gas, can't be used for checking gas related data/issues  
- Can't be used for bytecode-level stuff either, since it transpiles to smtlib through python(?)  
- Kontrol is a more complete version of Halmos  
  
- #### **Halmos commands**  
  - `halmos` is the command to run the FV tests  
  - `--function <funcName>` to specify the test  
  - `invariant-depth <int>` to specify how many sequenced function calls should be checked in each run  
  - `--loop <int>` to specify the number of loop runs present in the test  
  - `--solver-timeout-assertion <int>` specify timeout in assertion, 0 means no timeout, default is 1000 ms  
  
### **Certora**  
- Docs SUPER important -> [14]
- To set it up, in the root dir of the codebase, create dir `certora` which will have two sub-dirs, `conf` and `spec`  
- `conf` will have the configurations required for Certora to run, can be specified in the terminal but would be too long so ideal to have this dir  
- In the conf dir, create a file `example.conf`. This file will have a `"files": [...]` tag which will specify the target files, and `"verify":` will specify whatever we want to verify, basically the contract name, then a colon and the spec file location  
- In the conf file, there are a few more things to add:  
  - `optimistic_loop`- Basically, there's a loop in the function and you trust it  
  - `rule_sanity`- Certora will skip stupid rules  
  - `msg`- A custom message for the cli  
  - `wait_for_results`- Wait for results  
  - Check the docs to dig deeper into these configs  
- #### **Certora spec syntax**  
  - We can set up `rules` or `invariants` (along with other stuff, check docs, but these two are the most important parts)  
    - A `rule` specifies certain conditions after which an invariant should hold. Eg: Call x, y, and z then a should hold  
    - An `invariant` means that the invariant should hold at any state of the contract  
  - In the `methods` block, we specify the functions that will be used in the rule or invariant. It is basically like an interface, similar syntax to Solidity  
    - The functions declared in the `methods` block have a keyword attached at the end `envfree` which basically tells Certora that there are no environment variables involved like msg.sender, msg.value, etc.  
  - Also, seems like adding comments in the middle of the methods block throws an error(?)  
  - To add checks for function reverts, Certora has a keyword `@withrevert`. Eg: `foobar@withrevert(params)`  
  - There is a keyword `lastReverted` which is updated every time a Solidity function is invoked. If it reverts, lastReverted = true, else false  
  - In the URL generated, click on the rule that failed, check the call trace  
  > **Note:** If Certora is unsure if a variable can be changed, it will assume that the variable can be changed  
  - `HAVOC`ing: when Certora "randomizes" a variable in order to find a counter example  
  - Instead of `vm.assume(...)`, in Certora, we can just `require` the pre-conditions  
  - We refer to the contract being verified by using the keyword `currentContract`  
  - If a function is not `envfree`, you need to set up a env type variable `env e;` and then pass it as the first argument in the function call  
  - If an internal function needs to be tested, create a harness contract and wrap the function in an external function  
  - `definition`s server as type-checked macros in specifications, you can basically create one to use instead of constants, go through docs  
  - Use require instead of if conditions to set up pre-conditions  
  - Instead of `type(uint256).max`, it is `max_uint256` in Certora, which is a `mathint` type value  
  - `mathint` is a datatype present in Certora which can basically store an integer of any size, basically, never underflows or overflows  
  - For writing an `invariant`, all you need to do is include a boolean expression  
    - For example, if you have an invariant that can be set up in a simple boolean expression like `totalSupply() != 0;`, that's all you need to write in the `invariant`  
    - To add prechecks, create a block, in which we'll add the block `preserved {...}` which will contain the require statement  
  - **Note:** Read up more on path explosion problems and Modular Verification  
  - There might be some false-positives with Certora  
    - Add the generated result to a unit test to confirm whether the edge case is valid or not  
    - If not, add a require statement specifying to Certora to skip the specific values  
  - Parametric rules can be set up in Certora spec.
    - In a rule, define the following:  
      ```javascript
      rule xyz {
          method f;
          env e;
          calldataarg arg;
          f(e, arg);
          ... // any conditions
      }
      ```  
    - This rule will call any method in the contract with any env and any calldata arguments  
  - In Certora, `ghost` variables can be set up which can be used across `rule`s and `hook`s  
    - eg: `ghost uint256 sum;`  
    - This `ghost` variable is not initialized with 0, we can specify that like this: `ghost uint sum { init_state axiom sum == 0; }`  
      - Here, the `init_state` is a keyword to define an initial state of the variable  
      - The `axiom` keyword is added to assert that this initial state is always there  
    > **Note:** If a function is externally called and not recognized by Certora, it will also `DEFAULT HAVOC` the non-persistent ghost variables  
    - To make sure that the ghost variable isn't havoced, add the `persistent` keyword before it  
    - You can also declare ghost mappings!  
  - A `hook` in Certora is used to attach CVL code to certain low-level operations, such as loads and stores to specific storage variables  
    - eg: `hook Sstore totalSupply uint256 ts {...}`  
    - The above LoC basically says, "For any change made to the storage variable totalSupply, ts, do something"  
    - Hooks can be used for almost every EVM opcode, look at docs for syntax  
  - In Certora, there are two types of method declarations:  
    - Non-summary declarations (like the ones we have been using till now)  
    - Summary declarations (where we can ask certora to do something else with it than what it is intended to do)  
      - eg: `function totalSupply() external returns uint256 => ALWAYS(1);` This will always return 1  
    - Wildcard entries are also a type of method declaration where we can say that this function applies to any contract having this function selector  
      - eg: `function _.totalSupply() external returns uint256;`  
      - We can also add a summary to such declarations  
        - eg: `function _.totalSupply() external returns uint256 => ALWAYS(1);`  
    - Catch-all entries don't really make sense to me tbh  
      - eg: `function currentContract._ external returns uint256 => ALWAYS(1);`  
    - GOTO docs to understand method blocks better  
    - The `DISPATCHER` summary declaration basically indicates to Certora to whether look for the certain function's declaration in the given codebase and use that or to not do that and assume the worst  
      - `DISPATCHER(true)` indicates to look for a declaration of the function in the given contracts  
      - And, `DISPATCHER(false)` indicates the opposite  
    - `prover_args` is a flag for the config file that allows you to provide fine-grained tuning options to the Prover.  
      - One of these is `-optimisticFallback true` which indicates that if there are any calls to functions that are out of scope, they cannot arbitrarily change the state of our contract. Setting it to false would lead to default havocs  
  - Read up on `filtered` blocks in rules  
  - Can assert logical expressions like `assert balanceBefore > balanceAfter => e.msg.sender == owner`  
    - Here, we say that assert if balanceBefore is greater than balanceAfter, then msg.sender was the owner  
  - We can store a snapshot of storage using `storage`  
  - `lastStorage` gives us the current state of storage  
    - eg: `storage init = lastStorage;`  
    - `at init` would mean to rewind back to the init state of storage and then execute the command  
  - READ ABOUT `definition` KEYWORD! SEEMS AWESOME  
  - The Prover supports Foundry integration?! DO CHECK IT OUT  
  - Explicit type conversions can be done by adding `to_` prefix to the data-type  
    - eg: `to_bytes32(0)`  
  - For comparing function selectors: `f.selector == sig:xyz(uint).selector`  
    - The `sig:` prefix before manually entering a function signature is necessary in CVL  
  
  
  
  
**The Art and Science of Designing Specifications**  
----------  
### Unit-test Style Rules  
- Describe what they should return and revert  
- Describe what their arguments are  
- Describe what effects they should have  
  
### Variable Relationships and Changes  
- Variable Relationships  
  - For each pair of variables, ask "How are they related?"  
  - Each relationship can be written as an invariant  
  - Include related contracts!  
- Variable Changes  
  - For each variable, ask "How can it change, and when?"  
  - Each variable has one or more parametric rules(?)  
  
### State Transition Diagrams  
- Contracts have a natural "flow-chart" feel to them, these can be set up as rules  
- Define properties of each state  
- Each transition can have one or more rules, like variable changes  
  
### Stakeholder Rules  
- Think about what can go wrong from user's perspective  
- Each user (horror) story can be turned into a property  
  
### High-level Properties  
- If this goes up, that goes up (correlation)  
- If this is zero, that is zero  
- Two small operations are the same as one big operation (additivity)  
- Different ways to do the same thing should have the same effect  
  
  
  
  
**Random Notes**  
----------  
- **TWAP**: Time-Weighted Average Price  
  -  It is a price calculation method used in Uniswap(added in v2, improved in v3) that averages prices over a period of time.  
  
  
  
  
**Useful Links**  
----------  
  
> 1. [**openchain.xyz**](openchain.xyz) is a hex values database, can search random hex values to decrypt them  
> 2. [**codeslaw.app**](codeslaw.app) is a tool to look up function signatures called anywhere on the mainnet  
> 3. [**etherscan.deth.net**](etherscan.deth.net) while looking at any verified contracts on `etherscan.io`, change the postfix to `.deth.net` to see the code in a virtual VSC sim  
> 4. [**Ethereum EIPs**](eips.ethereum.org)   
> 5. [**ZKSync documentation**](docs.zksync.io)  
> 6. [**EVM Opcodes**](evm.codes)  
> 7. [**Dedaub**](app.dedaub.com)  is an EVM bytecode decompiler.  
> 8. [**Heimdall-rs**](https://github.com/Jon-Becker/heimdall-rs) is an EVM toolkit that can be used for EVM bytecode disassembly/decompiling.  
> 9. [**The Art of Auditing**](https://web3-sec.gitbook.io/art-of-auditing) Whenever you feel stuck or just need some motivation.  
> 10. [**sc-exploits-minimized**](https://github.com/Cyfrin/sc-exploits-minimized) Check out all the exploits to have a better understanding.  
> 11. [**ToB Secure Contracts**](https://secure-contracts.com) Guides for all the tools I need to use and better understanding of invariants.  
> 12. [**Foundry Integration Docs for Certora**](https://docs.certora.com/en/latest/docs/cvl/foundry-integration.html) will guide you how to use your fuzz tests as FV specs in Certora!  
  
  
  
  
**References**  
----------
[1] nascentxyz / simple-security-toolkit  
[2] ZhangZhuoSJTU / Web3Bugs  
[3] Cyfrin / security-and-auditing-full-course-s23  
[4] docs.codehawks.com - How to determine a finding severity  
[5] @openzeppelin/contracts/util/ReentrancyGuard.sol  
[6] pcaversaccio / reentrancy-attacks  
[7] Cyfrin / sc-exploits-minimized - src/mishandling-of-eth  
[8] crytic / properties  
[9] d-xo / weird-erc20  
[10] secure-contracts.com  
[11] crytic / building-secure-contracts / program-analysis / echidna / exercises / exercise2  
[12] KatrixReloaded / FoundryLottery  
[13] a16z / halmos-cheatcodes  
[14] https://docs.certora.com/en/latest/docs/cvl/index.html -> Certora Docs  
  
  
  
  
**Questions**  
----------  
&#x2610; What are Linux ELF binaries?  
&#x2610; What are WASM modules?  
&#x2610; What are Linux packages, managers, kernel, distros, etc.?  
