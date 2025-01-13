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
  
### Opcodes  
- Everything costs gas. Solidity automatically identifies which variable goes in memory and which variable goes in storage.  
- Storing in memory(`MSTORE`) costs a minimum of 3 gas while storing in storage(`SSTORE`) costs a minimum of 100 gas.  
- Adding two values from stack (`ADD`) takes 3 gas. It takes two values, a(eg., `PUSH1 0x01`) and b(eg., `PUSH1 0x03`), from stack and returns the sum of the two(eg., `PUSH1 0x04`). It will only add the two values at the top of the stack.  
- `PUSH<number>` adds a value to the stack. The `<number>` defines the number of bytes of the data. `PUSH0` pushes 0 to the stack.  
- `CALLDATALOAD` loads the first 32 bytes of calldata  
- `SHR` shifts a 32-byte value to the right by the amount of bits specified  
- `JUMPI` jumps to a destination program counter if a condition is met  
- `DUP1` duplicates the value on top of the stack. Similarly, `DUP2` adds a duplicate of the value second in the stack to the top of the stack, and so on.  
- `REVERT` reverts the code so that if no conditions are met, the function doesn't keep executing whatever is next.  
- In memory, the first slot is `0x00`, the second slot is not `0x01`, it is `0x20`, since it is the first slot after 32-bytes, then `0x40`, and so on.  
- `0x40` is the free memory pointer **in Solidity**. You access that to see which slot in memory is free to use. During contract creation, `0x80`(128-bytes) is set as the free memory slot. In Huff, we usually don't use 0x40 as the free memory pointer as we didn't need it.  
  - Example -  
    ```javascript
    contract Example {
        function addTwo(uint256 _param) public pure returns(uint256) {
            uint256 two = 2; // This line as reference
            return _param + two;
        }
    }
    ```  

    That particular line's opcode:  
    ```
    PUSH1 0x2       // [2]
    PUSH1 0x40      // [0x40, 2]
    MLOAD           // [0x80, 2] (Loads the free memory slot from 0x40)
    MSTORE          // [] (Stores the value 2 in the slot 0x80)
    ```  
    After that is stored at 0x80, the free memory pointer will point to `0x6a`, which is 32-bytes after `0x80`  
- `CODECOPY` stores the runtime code in memory on-chain. It takes the top 3 values from stack, the top one being the byte offset in memory where result will be copied, the next one being the offset in code from where we need to start copying and the third one being the byte size to copy.   
- `CALLDATASIZE` pushes the byte size of the calldata to stack.  
- `SWAP1` swaps the places of the value on top of the stack with the value right below it. Similarly, `SWAP2` swaps the places of the value on top of the stack and the value third in stack, and so on.  
  
### Huff  
- Commands-  
    - `huffc <file-location>` - To compile the code  
    - `huffc <file-location> -b` - To compile the code and get the bytecode of the smart contract  
    - `huffc <file-location> --bin-runtime` - To compile the code and get the runtime bytecode  
  
- Features-  
    - Just to make the code easier to understand and to avoid having to manually get each function selector.  
        - 1st step : `#define function function_name() nonpayable returns() {}` - Define like in Solidity, nonpayable keyword in Huff.  
        - 2nd step : Instead of pushing the function sig manually like `0x12345678`, you can write the `__FUNC_SIG(function_name)` statement.  
    - Huff makes working with storage easier. Every storage slot is going to be 32 bytes.  
        - `FREE_STORAGE_POINTER()` essentially a counter that provides with a slot that is currently open to store data in.  
        