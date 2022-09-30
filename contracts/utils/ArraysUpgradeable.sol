// SPDX-License-Identifier: UNLICENSED

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

    function toString(uint64[2] memory array) internal pure returns (string memory) {
        return string(abi.encode("[", array[0], ",", array[1], "]"));
    }

    function toString(uint256[] memory array) internal pure returns (string memory) {
        uint256 l = array.length;
        string[] memory strings = new string[](l * 2 - 1);
        for (uint256 i = 0; i < l; i++) {
            strings[2 * i] = string(abi.encode(array[i]));
            if (i + 1 < l) strings[2 * i + 1] = ",";
        }
        return string(abi.encode("[", strings, "]"));
    }

    function toString(bytes32[] memory array) internal pure returns (string memory) {
        uint256 l = array.length;
        string[] memory strings = new string[](l * 2 - 1);
        for (uint256 i = 0; i < l; i++) {
            strings[2 * i] = string(abi.encode(array[i]));
            if (i + 1 < l) strings[2 * i + 1] = ",";
        }
        return string(abi.encode("[", strings, "]"));
    }
}
