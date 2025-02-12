// SPDX-Licence-Identifier: MIT
pragma solidity 0.8.28;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract KemsguyAirdrop is Ownable {

    //create an interfce for our token 
    ERC20 public token; 

    mapping(address => bool) public verification; //mapping to check if an address has gotten an airdrop or not 

    uint public airdropAmount; 

    event TransferDrop (address indexed _to, uint _amount);
    event Withdrawal (address indexed _to, uint _amount);


    constructor (address _token, uint _amount) {
        require(address(_token) != address(0), "Invalid token (0) address");
        require(_amount > 0, "Rejected, Needs to be more than 0");
        token = ERC20(_token); 
        airdropAmount = _amount;
    }

    function getDrop() external {
        require(msg.sender != address(0), "Invalid address");
        require (verification[msg.sender] == true, "Address not whitelisted"); // address has to be whitelisted beofre airdrop can be sent  

        
        verification[msg.sender] = true;


        token.transfer(msg.sender, airdropAmount);
        emit TransferDrop (msg.sender, airdropAmount);
    }

    function withdrawToken() external onlyOwner {
        uint remainedAmount = token.balanceOf(address(this));
        require(remainedAmount > 0 , "Rejected, No token left");
        token.transfer(owner(), remainedAmount);
        emit Withdrawal (owner(), remainedAmount);
    }

    // function that will change amount of airdrop
    function changeDropAmount( uint _newAmount) external onlyOwner{
        require(_newAmount > 0, "Rejected, Amount Needs to be more than 0");
        airdropAmount = _newAmount; 
    }

    // function that will change the token address 
    function newToken (address _newTokenAddressCreator) external onlyOwner {
        require(_newTokenAddressCreator != address(0), "Invalid token");
        token = ERC20(_newTokenAddressCreator);
    } 

    // Function that changes the verification status of an address
    function changeVerification (address _address) external onlyOwner {
        verification[_address] = false;
    }

    //function that will change the owner of the contract
    function changeOwner (address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "Invalid address");
        transferOwnership(_newOwner);
    }

    //function to whitelist Addresses
    function whitelistAddress (address _address) external onlyOwner {
        require(_address != address(0), "Invalid address");
        verification[_address] = true; // Change  the address to be true in the verification mapping

    }

}