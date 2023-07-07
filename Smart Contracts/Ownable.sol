// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0 .0;

/**
 * @title Ownable
 * @author Tan Ching Hung
 * @notice This contract is only for educational purposes. All rights reserved.
 * @dev Contract that defines the owner of a contract and provides basic authorization control.
 */

contract Ownable {
    /**
     * @dev Contract owner.
     */
    address private contractOwner;

    /**
     * @dev Event when a new owner is set.
     * @param oldOwner The old owner of the contract
     * @param newOwner The new owner of the contract
     */
    event OwnerSet(address indexed oldOwner, address indexed newOwner);

    /**
     * @dev Ownable constructor. Sets the contract owner as the sender who deploys the contract.
     */
    constructor() {
        contractOwner = msg.sender;
        emit OwnerSet(address(0), contractOwner);
    }

    /**
     * @dev Function to transfer ownership of the contract.
     */
    function transfer(address newOwner) public onlyOwner {
        contractOwner = newOwner;
        emit OwnerSet(contractOwner, newOwner);
    }

    /**
     * @dev Modifier to limit access of a function to owner only.
     */
    modifier onlyOwner() {
        require(isOwner(), "Only owner can call this function.");
        _;
    }

    /**
     * @dev Function to check if sender is the contract owner.
     */
    function isOwner() internal view returns (bool) {
        return msg.sender == contractOwner;
    }
}
