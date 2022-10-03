// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "../HypercertMinter.sol";

contract HypercertMinterUpgrade is HypercertMinter {
    event Split(uint256 fromID, uint256[] toID);

    /// @notice Contract constructor logic
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function split(uint256 id) public {
        require(_exists(id), "Mint: token does not exist");
        uint256[] memory newIDs = new uint256[](1);
        newIDs[0] = id + 1;
        emit Split(id, newIDs);
    }
}
