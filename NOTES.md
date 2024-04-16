Transactions - Function call
1. Nonce: tx count for the account
2. Gas Price: price per unit of gas(in wei)
3. Gas Limit: max gas that this tx can use
4. To: address that the tx is sent to
5. Value: amount of wei to send
6. Data: what to send to the To address
7. v,r,s: components of tx signature

Transactions - Contract Deployment
1. Nonce: tx count for the account
2. Gas Price: price per unit of gas(in wei)
3. Gas Limit: max gas that this tx can use
4. To: empty
5. Value: amount of wei to send
6. Data: contract init code & contract bytecode
7. v,r,s: components of tx signature

we can send the data field of the tx ourselves with our function call hexcode
call: how we call functions to change the state of the blockchain
staticcall: this is how (at a low level) we do our "view" or "pure" function calls, and potentially don't change the blockchain

tx = {
    nonce: nonce,
    gasPrice: 100000000,
    gasLimit: 100000,
    to: null,
    value: 0,
    data: "0x608060...0f0345", //EVM level data, low level
    chainId: 1337,
}

For example-
(bool success, ) = recentWinner.call{value: address(this).balance}("");
Here, we change the value (Line 6) field of a transaction directly, the parantheses at the end is where we put the data (Line 7)
In our {} we are able to pass specific fields of a transaction, like value
In our () we are able to pass data in order to call a specific function but there was no function we wanted to call in Line 34.




selfdestruct is a keyword in solidity that is used to delete/destroy a contract.
Proxies can be used to make changes to a smart contract. Kinda negates the "decentralization" part of blockchain. Leads to rag-pulling.




-- Rough approximation of audit duration --
LoC : Duration - 
100 : 2.5 days
500 : 1 week
1000 : 1-2 weeks
2500 : 2-3 weeks
5000 : 3-5 weeks
5000+ : 5+ weeks

Findings are listed by severity in a report - Highs, Mediums, Lows, Informational, Gas efficiencies and non-critical (Last 3 are not vulnerabilities, but ways to improve code).