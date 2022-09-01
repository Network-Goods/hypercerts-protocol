// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "./HypercertMinterV0.sol";

/// @title Hypercert Minting logic
/// @notice Contains functions and events to initialize and issue a hypercert
/// @author bitbeckers, mr_bluesky
//FIXME Merge in changes to main contract. This upgrade is used to aggregate changes
contract HypercertMinterV1 is HypercertMinterV0 {
    string public constant NAME = "Impact hypercertificates";

    function updateVersion() external onlyRole(UPGRADER_ROLE) {
        _version += 1;
    }
}
