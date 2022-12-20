// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import { MerkleProofUpgradeable } from "oz-upgradeable/utils/cryptography/MerkleProofUpgradeable.sol";
import { IAllowlist } from "./interfaces/IAllowlist.sol";

error DuplicateEntry();
error DoesNotExist();
error Invalid();

/// @title Interface for hypercert token interactions
/// @author bitbeckers
/// @notice This interface declares the required functionality for a hypercert token
/// @notice This interface does not specify the underlying token type (e.g. 721 or 1155)
contract AllowlistMinter is IAllowlist {
    using MerkleProofUpgradeable for bytes32[];

    event AllowlistCreated(uint256 tokenID, bytes32 root);
    event LeafClaimed(uint256 tokenID, bytes32 leaf);

    mapping(uint256 => bytes32) internal merkleRoots;
    mapping(uint256 => mapping(bytes32 => bool)) public hasBeenClaimed;

    function isAllowedToClaim(
        bytes32[] calldata proof,
        uint256 claimID,
        bytes32 leaf
    ) public view returns (bool isAllowed) {
        if (merkleRoots[claimID].length == 0) revert DoesNotExist();
        isAllowed = proof.verifyCalldata(merkleRoots[claimID], leaf);
    }

    function _createAllowlist(uint256 claimID, bytes32 merkleRoot) internal {
        if (merkleRoots[claimID] != "") revert DuplicateEntry();

        merkleRoots[claimID] = merkleRoot;
        emit AllowlistCreated(claimID, merkleRoot);
    }

    function _processClaim(bytes32[] calldata proof, uint256 claimID, uint256 amount) internal {
        if (merkleRoots[claimID].length == 0) revert DoesNotExist();

        bytes32 node = keccak256(abi.encodePacked(msg.sender, amount));

        if (hasBeenClaimed[claimID][node]) revert DuplicateEntry();
        if (!proof.verifyCalldata(merkleRoots[claimID], node)) revert Invalid();
        hasBeenClaimed[claimID][node] = true;

        emit LeafClaimed(claimID, node);
    }
}
