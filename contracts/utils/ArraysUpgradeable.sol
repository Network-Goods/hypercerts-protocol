// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

/**
 * @dev Collection of functions related to array types.
 */
library ArraysUpgradeable {
    /**
     * @dev calculate the sum of the elements of an array
     */
    function getSum(uint8[] memory array) internal pure returns (uint256) {
        if (array.length == 0) {
            return 0;
        }

        uint256 sum = 0;
        for (uint256 i = 0; i < array.length; i++) sum += array[i];
        return sum;
    }
}
