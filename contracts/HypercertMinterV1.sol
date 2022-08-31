// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "./HypercertMinterV0.sol";

/// @title Hypercert Minting logic
/// @notice Contains functions and events to initialize and issue a hypercert
/// @author bitbeckers, mr_bluesky
//TODO Merge in changes to main contract. This upgrade is used to aggregate changes
contract HypercertMinterV1 is HypercertMinterV0 {
    string public constant name = "Impact hypercertificates";

    /// @notice gets the current version of the contract
    function version() public pure virtual override returns (uint256) {
        return 0;
    }
}
