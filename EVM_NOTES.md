# EVM Notes  

## encode(), encodePacked(), encodeWithSignature(), encodeWithSelector(), encodeCall()   
  
For making low-level calls to external contracts' functions  
  
### encode()  
When encoding static types, it is just one part, the data itself in hex.
When encoding dynamic datatypes, there are three parts to it in the encoded format - offset, length and the data itself. Each part is 32 bytes long. The offset acts as the pointer to the actual data.  
For example -  
Input:  
```javascript
return abi.encode("hello",1337,"world");
```  
Output:  
```
0000000000000000000000000000000000000000000000000000000000000060 // offset of "hello"  
0000000000000000000000000000000000000000000000000000000000000539 // 1337 in hex  
00000000000000000000000000000000000000000000000000000000000000a0 // offset of "world"  
0000000000000000000000000000000000000000000000000000000000000005 // length of "hello"  
68656c6c6f000000000000000000000000000000000000000000000000000000 // data of "hello" in hex  
0000000000000000000000000000000000000000000000000000000000000005 // length of "hello"  
776f726c64000000000000000000000000000000000000000000000000000000 // data of "world" in hex
```
**Note**: When you are running EVM in the memory, dynamic types will be in only 2 parts - the length and the data (no offset). When there are 3 parts, it is the ABI encoding of the datatype.
  
  
### encodePacked()  
Encoded in hex, without the three parts for dynamic types mentioned above  
For example -  
Input:  
```javascript
return abi.encode("hello",1337,"world");
```  
Output:  
`68656c6c6f0539776f726c64`  
//basically gibberish, not useful  
  
  
### encodeWithSignature()  
Just appends the function selector with the rest of the calldata staying the same as in `encode()`  
For example -  
Input:  
```javascript
return abi.encodeWithSignature("someFunc(string, uint256, string)", "hello", 1337, "world");
```  
Output:  
```
6a49c500 // function selector for "someFunc(string, uint256, string)", rest is the same...  
0000000000000000000000000000000000000000000000000000000000000060  
0000000000000000000000000000000000000000000000000000000000000539  
00000000000000000000000000000000000000000000000000000000000000a0  
0000000000000000000000000000000000000000000000000000000000000005  
68656c6c6f000000000000000000000000000000000000000000000000000000  
0000000000000000000000000000000000000000000000000000000000000005  
776f726c64000000000000000000000000000000000000000000000000000000   
```
  
  
### encodeWithSelector()  
Exactly the same output as `encodeWithSignature()`, just the syntax of the parameters is different.  
For example -  
Input:  
```javascript
return abi.encodeWithSelector(Helper.someFunc.selector, "hello", 1337, "world");
```  
Output: Exactly the same  
  
  
### encodeCall()  
Exactly the same output as `encodeWithSignature()`, again, the syntax of the parameters is different.  
For example -  
Input:  
```javascript
return abi.encodeCall(Helper.someFunc, ("hello",1337,"world");
```  
Output: Exactly the same  
  
  
## Solidity Return vs. Yul Return  
  
Suppose you have set a nonReentrant modifier of your own, and want to reset the status of the function after it has been executed, so that it can be used again later on.  
```javascript
uint256 _status = 1;
uint256 ENTERED = 2;
uint256 NOT_ENTERED = 1;
modifier nonReentrant {
    require(_status != ENTERED);
    _status = ENTERED;
  
    _; // function execution here
  
    _status = NOT_ENTERED; // post function execution
}
```
If you are doing the normal solidity return in a function with this above modifier, the EVM understands that there is code to be executed after the function call, and acts accordingly.  
Example -  
```javascript
function testSolidityReturn() public nonReentrant returns(uint256) {
    return 0x42;
}
```
  
However, if you are returning in Yul, it is immediate, brutal execution. Nothing runs after that return statement. If you are doing a Yul return in a function with the above modifier, the `_status` will set its value to `ENTERED` and never reset. This will lead to a DoS, since it will now forever be in the `ENTERED` state and reentrancies are not allowed.  
```javascript
function testYulReturn() public nonReentrant returns(uint256) {
    assembly {
        //mstore(offset,value)
        mstore(0x00, 0x42);
        //return(offset,size)
        return(0x00, 0x20);
    }
}
```
  
## Assembly with Huff and Yul  
  
Huff and Yul are low-level languages for writing smart contracts. They can be used to make code insanely optimized for gas.  
  
- Everything costs gas. Solidity automatically identifies which variable goes in memory and which variable goes in storage.  
    - Storing in memory(`MSTORE`) costs a minimum of 3 gas while storing in storage(`SSTORE`) costs a minimum of 100 gas.  
    - Adding two values from stack (`ADD`) takes 3 gas. It takes two values, a(eg., `PUSH1 0x01`) and b(eg., `PUSH1 0x03`), from stack and returns the sum of the two(eg., `PUSH1 0x04`). It will only add the two values at the top of the stack.  
    - `PUSH<number>` adds a value to the stack. The `<number>` defines the number of bytes of the data. `PUSH0` pushes 0 to the stack.  
    - `CALLDATALOAD` loads the first 32 bytes of calldata  
    - `SHR` shifts a 32-byte value to the right by the amount of bits specified  
    - `JUMPI` jumps to a destination program counter if a condition is met  
  
### Huff  
- Commands-  
    - `huffc <file-location>` - To compile the code  
    - `huffc <file-location> -b` - To compile the code and get the bytecode of the smart contract  
    - `huffc <file-location> --bin-runtime` - To compile the code and get the runtime bytecode  