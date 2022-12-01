// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IHypercertMinter {
    function mintClaim(uint256 units, string memory uri) external;

    function mintClaimWithFractions(uint256[] memory fractions, string memory uri) external;
}
