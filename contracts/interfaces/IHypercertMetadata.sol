// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

/**
 * @title Hypercert metadata generator interface
 */
interface IHyperCertMetadata {
    function generateSlotURI(uint256 slotId) external view returns (string memory);

    function generateTokenURI(uint256 slotId, uint256 tokenId) external view returns (string memory);
}
