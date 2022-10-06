// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "../HyperCertMinter.sol";

contract HyperCertMinterUpgrade is HyperCertMinter {
    event Split(uint256 fromID, uint256[] toID);

    /// @notice Contract constructor logic
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function mockedUpgradeFunction() public returns (bool) {
        return true;
    }
}
