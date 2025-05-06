# Node Guardians  
  
## Understanding Storage  
### Storage Layout  
- Data is stored in slots in storage, right-to-left in each slot  
- Suppose there's a mapping in storage slot 3. To find the value at key `x`, the value would be found at slot `keccak256(abi.encode(x, 3))` (`keccak(key || i)`; where i is the storage slot of the map).  
  - If it is a nested mapping and you need to find `map[x][y]`, `a = keccak(x || i)`, then `b = keccak(y || a)`  
- Storage has the length of the array at slot i, the data is found at `uint(keccak256(abi.encode(i))) + index`.  
  
### Storage Efficiency  
- Reading and writing to memory or stack is much cheaper in gas than storage.  
  - Cache values to memory instead of reading/writing from storage multiple times  
- Warm access vs. cold access  
  - If a storage var is accessed for the first time and has not been initialized (val = 0), it is called a cold access. Costs 21000 gas to write on it.  
  - However, if I assign a non-zero value to it at the time of declaration, the first write on it will cost 2000 gas. This is known as a warm access.  
- `unchecked` wherever safe  
  
## Gas Optimization  
### Writing Gas Optimized Contracts  
- Packing slots wherever possible  
  - Packing slots may not be gas-efficient if only one of the vars is being accessed from a slot where multiple values are stored  
- `delete` is no longer gas-efficient as it refunds lesser gas than what is required for accessing the storage slot  
- `constant` and `immutable` state vars are NOT stored in storage, they are hardcoded into the bytecode  
  - They can be read for a fraction of the gas cost since no storage read is required  
  - `immutable` vars cannot be used in a pure function  
- If we're not mutating function calls' arguments, it is better to label them as `calldata` instead of `memory` as writing them as memory would mean that the contract would have to copy the calldata into memory, whereas, calldata args would directly point to the calldata location and are cheaper to use  
- For certain arithmetic operations, bitwise operators can be gas-efficient alternatives  
  - Multiplication by a power of 2  
  - Division by a power of 2  
  ```
  variable << 1;
  variable * 2'
  ```
- `>=` is slightly cheaper than `>`  
- Using 2 `require` statements is cheaper than using 1 with `&&`  
- Writing on a used storage slot is cheaper than writing on a new one  
- Functions declared earlier are cheaper to call! Order and names of functions affect their gas cost  
- `++i` is slightly cheaper than `i++` and `i = i+1`  
- `internal` and `private` functions can eliminate duplicate code  
- If there is a value being read in a loop multiple times, we can cache it in the loop, it's cheaper  
  
## Standalone  
### Merkle Proof  
- Merkle trees sort **pairs** and not the entire level  
- The hash values are treated as 256-bit integers and compared to see which is the lower value, the lower value is added to the left and the greater to the right, and then they are hashed together  
- This pair sorting is done at each level, irrespective of the leaves  
