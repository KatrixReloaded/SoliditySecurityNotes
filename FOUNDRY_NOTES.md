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