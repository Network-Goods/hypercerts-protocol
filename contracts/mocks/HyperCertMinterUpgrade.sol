// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "../HyperCertMinter.sol";

contract HyperCertMinterUpgrade is HyperCertMinter {
    /// @notice Contract constructor logic
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function mockedUpgradeFunction() public pure returns (bool) {
        return true;
    }
}
