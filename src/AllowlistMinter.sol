// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {
    MerkleProofUpgradeable
} from "lib/openzeppelin-contracts-upgradeable/contracts/utils/cryptography/MerkleProofUpgradeable.sol";

error DuplicateEntry();
error DoesNotExist();
error NotAllowed();

contract AllowlistMinter {
    using MerkleProofUpgradeable for bytes32[];

    event AllowlistCreated(uint256 claimID, bytes32 root);
    event LeafClaimed(uint256 claimID, bytes32 leaf);

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
        if (!proof.verifyCalldata(merkleRoots[claimID], node)) revert NotAllowed();
        hasBeenClaimed[claimID][node] = true;

        emit LeafClaimed(claimID, node);
    }
}
