// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

/**
 * @dev Collection of functions related to array types.
 */
library StringsExtensions {
    /**
     * @dev returns either "true" or "false"
     */
    function toString(bool value) internal pure returns (string memory) {
        if (value) return "true";
        return "false";
    }
}
