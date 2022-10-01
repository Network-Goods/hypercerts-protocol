// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

struct ClaimData {
    uint256 id;
    uint64[2] workTimeframe;
    uint64[2] impactTimeframe;
    string[] workScopes;
    string[] impactScopes;
    uint256[] fractions;
    uint256 totalUnits;
    string name;
    string description;
    string uri;
}

/**
 * @title Hypercert metadata generator interface
 */
interface IHypercertMetadata {
    function slotURI(ClaimData calldata claim) external pure returns (string memory);

    function tokenURI(ClaimData calldata claim, uint256 balance) external pure returns (string memory);
}
