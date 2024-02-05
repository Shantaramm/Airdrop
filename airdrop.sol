
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {Error} from "./Constants.sol";

/**
 * @title Airdrop
 * @dev A contract for distributing tokens to whitelisted users using Merkle proofs.
 */
contract Airdrop is ERC20, Ownable {

    /**
     * @dev The amount of tokens each user can claim.
     */
    uint256  amountPerUser = 1000 * 10 ** decimals();

    /**
     * @dev The Merkle root for the whitelist.
     */
    bytes32 public root;

    /**
     * @dev A mapping to keep track of claimed users.
     */
    mapping(address => bool) public usersClaimed;

    /**
     * @dev The total number of users eligible for the airdrop.
     */
    uint8 constant allUsers = 100;

    /**
     * @dev The current user count.
     */
    uint8 currentUser;

    /**
     * @dev Constructor to initialize the contract with the token name and symbol, and set the initial owner.
     * @param initialOwner The address of the initial owner.
     */
    constructor(address initialOwner)
        ERC20("TopToken", "TOP")
        Ownable(initialOwner) {}

    /**
     * @dev Sets the Merkle root for the whitelist.
     * @param _root The new Merkle root.
     */
    function setRoot(bytes32 _root) public onlyOwner {
        root = _root;
    }

    /**
     * @dev Allows a user to claim their tokens using a Merkle proof.
     * @param _proof The Merkle proof for the user.
     */
    function claim(bytes32[] calldata _proof) external {
        require(allUsers >= currentUser, Error.OVER_USERS);
        require(!usersClaimed[msg.sender], Error.WAS_CLAIMED);
        require(MerkleProof.verify(_proof, root, keccak256(abi.encodePacked(msg.sender))), Error.NOT_WHITELIST);
        _mint(msg.sender, amountPerUser);
        ++currentUser;
        usersClaimed[msg.sender] = true;
    }
}