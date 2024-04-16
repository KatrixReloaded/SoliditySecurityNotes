// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FundDistribution {
    // Fund structure
    struct Fund {
        string name;
        uint256 totalSupply;
        uint256 pricePerUnit;
    }
    
    // Mapping to store funds by their ID
    mapping(uint256 => Fund) public funds;
    
    // Mapping to store balances for each customer and fund ID
    mapping(address => mapping(uint256 => uint256)) public customerBalances;
    
    // Event to emit when a fund is purchased
    event FundPurchased(address indexed customer, uint256 fundID, uint256 amount);
    
    // Create a new fund
    function createFund(
        uint256 fundID,
        string memory name,
        uint256 totalSupply,
        uint256 pricePerUnit
    ) public {
        require(totalSupply > 0, "Total supply must be greater than zero");
        require(pricePerUnit > 0, "Price per unit must be greater than zero");
        
        // Create a new fund and store it in the mapping
        funds[fundID] = Fund({
            name: name,
            totalSupply: totalSupply,
            pricePerUnit: pricePerUnit
        });
    }
    
    // Purchase a fund
    function purchaseFund(uint256 fundID, uint256 amount) public payable {
        require(funds[fundID].totalSupply > 0, "Fund does not exist");
        require(amount > 0, "Amount must be greater than zero");
        
        // Calculate the total cost
        uint256 totalCost = amount * funds[fundID].pricePerUnit;
        
        // Check if the customer sent enough Ether
        require(msg.value == totalCost, "Incorrect Ether sent");
        
        // Update the total supply and customer balance
        require(funds[fundID].totalSupply >= amount, "Insufficient fund supply");
        funds[fundID].totalSupply -= amount;
        customerBalances[msg.sender][fundID] += amount;
        
        // Emit an event for the purchase
        emit FundPurchased(msg.sender, fundID, amount);
    }
    
    // View fund details
    function viewFund(uint256 fundID) public view returns (Fund memory) {
        require(funds[fundID].totalSupply > 0, "Fund does not exist");
        return funds[fundID];
    }
    
    // View customer balance for a specific fund
    function viewCustomerBalance(address customer, uint256 fundID) public view returns (uint256) {
        return customerBalances[customer][fundID];
    }
}
