// SPDX-License-Identifier: MIT
pragma solidity >=0.5.16 <0.9.0;

contract SimpleBank {

    /* State variables */
	address public owner; // allow anyone to see bank owner.

	constructor() public { // contract creator owns the bank.
		owner = msg.sender;
	}

    // protect our users' balance amount from other contracts.
    mapping (address => uint) private balances;

	// Compiler automatically creates getter functions for all public state variables.
    // Addllow other contracts to see if a user is enrolled.
    mapping (address => bool) public enrolled;
    
    // Events publicize actions to external listeners (not other contracts).
    event LogEnrolled(address accountAddress); // Add an argument for this event, an accountAddress
    event LogDepositMade(address accountAddress, uint amount); // Add 2 arguments for this event, an accountAddress and an amount
    event LogWithdrawal(address accountAddress, uint withdrawAmount, uint newBalance); // Hint: it should take 3 arguments: an accountAddress, withdrawAmount and a newBalance 

    /* Functions */

    // Fallback function called when invalid data is sent; so eth sent to this contract is reverted if this contract fails.
    function () external payable {
        revert();
    }

    function getBalance() public view returns (uint) {
		require(enrolled[msg.sender], "User must first be enrolled."); 
		return balances[msg.sender];
    }

    function enroll() public returns (bool){
		if (enrolled[msg.sender]) {
			revert("User is already enrolled.");
		}
		enrolled[msg.sender] = true;
		balances[msg.sender] = 0;
		emit LogEnrolled(msg.sender);
		return true;
    }

    function deposit() public payable returns (uint) {
		require(enrolled[msg.sender], "User must first be enrolled."); 
		balances[msg.sender] += msg.value;
		emit LogDepositMade(msg.sender, msg.value);
		return balances[msg.sender];
    }

    function withdraw(uint withdrawAmount) public returns (uint) {
		require(enrolled[msg.sender] == true, "User must be enrolled."); 
		require(balances[msg.sender] >= withdrawAmount, "User has inadequate balance."); 
		balances[msg.sender] -= withdrawAmount; 
		(bool success,) = msg.sender.call.value(withdrawAmount)("");
		require(success, "Failed to send Ether.");
		emit LogWithdrawal(msg.sender, withdrawAmount, balances[msg.sender]);
		return balances[msg.sender];
    }
}
