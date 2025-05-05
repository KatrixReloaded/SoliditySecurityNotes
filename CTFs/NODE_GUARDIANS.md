# Node Guardians  
  
## Understanding Storage  
### Storage Layout Quest  
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
