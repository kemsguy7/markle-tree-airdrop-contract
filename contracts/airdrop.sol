// SPDX-Licence-Identifier: MIT
pragma solidity 0.8.28;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract KemsguyAirdrop is Ownable {

    //create an interfce for our token 
    ERC20 public token; // SPDX-License-Identifier: MIT
    pragma solidity 0.8.28;
    
    import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
    import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
    import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
    
    error InvalidAddress();
    error InvalidTokenAddress();
    error InvalidAmount();
    error AddressNotWhitelisted();
    error AlreadyClaimed();
    error NoTokensLeft();
    error InvalidMerkleProof();
    
    contract KemsguyAirdrop is Ownable {
        // State variables
        ERC20 public token;
        bytes32 public merkleRoot;
        uint public airdropAmount;
        
        // Mapping to track claimed airdrops
        mapping(address => bool) public hasClaimed;
        
        // Events
        event TransferDrop(address indexed _to, uint _amount);
        event Withdrawal(address indexed _to, uint _amount);
        event MerkleRootUpdated(bytes32 newMerkleRoot);
        
        constructor(
            address _token, 
            uint _amount,
            bytes32 _merkleRoot
        ) {
            if (_token == address(0)) revert InvalidTokenAddress();
            if (_amount == 0) revert InvalidAmount();
            
            token = ERC20(_token);
            airdropAmount = _amount;
            merkleRoot = _merkleRoot;
        }
        
        /**
         * @notice Claim airdrop tokens using Merkle proof
         * @param _proof Merkle proof to verify eligibility
         */
        function claimDrop(bytes32[] calldata _proof) external {
            // Check if address has already claimed
            if (hasClaimed[msg.sender]) revert AlreadyClaimed();
            
            // Verify the merkle proof
            bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
            if (!MerkleProof.verify(_proof, merkleRoot, leaf)) revert InvalidMerkleProof();
            
            // Mark as claimed and transfer tokens
            hasClaimed[msg.sender] = true;
            
            bool success = token.transfer(msg.sender, airdropAmount);
            if (!success) revert();
            
            emit TransferDrop(msg.sender, airdropAmount);
        }
        
        /**
         * @notice Withdraw remaining tokens (only owner)
         */
        function withdrawToken() external onlyOwner {
            uint remainedAmount = token.balanceOf(address(this));
            if (remainedAmount == 0) revert NoTokensLeft();
            
            bool success = token.transfer(owner(), remainedAmount);
            if (!success) revert();
            
            emit Withdrawal(owner(), remainedAmount);
        }
        
        /**
         * @notice Update airdrop amount (only owner)
         */
        function changeDropAmount(uint _newAmount) external onlyOwner {
            if (_newAmount == 0) revert InvalidAmount();
            airdropAmount = _newAmount;
        }
        
        /**
         * @notice Update token address (only owner)
         */
        function newToken(address _newTokenAddress) external onlyOwner {
            if (_newTokenAddress == address(0)) revert InvalidTokenAddress();
            token = ERC20(_newTokenAddress);
        }
        
        /**
         * @notice Update merkle root (only owner)
         */
        function updateMerkleRoot(bytes32 _newMerkleRoot) external onlyOwner {
            merkleRoot = _newMerkleRoot;
            emit MerkleRootUpdated(_newMerkleRoot);
        }
        
        /**
         * @notice Check if address is eligible for airdrop
         * @param _account Address to check
         * @param _proof Merkle proof for the address
         */
        function isEligible(
            address _account,
            bytes32[] calldata _proof
        ) public view returns (bool) {
            bytes32 leaf = keccak256(abi.encodePacked(_account));
            return MerkleProof.verify(_proof, merkleRoot, leaf);
        }
    }

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