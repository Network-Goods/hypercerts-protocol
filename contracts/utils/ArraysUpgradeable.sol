// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";

/**
 * @dev Collection of functions related to array types.
 */
library ArraysUpgradeable {
    using StringsUpgradeable for uint256;

    /**
     * @dev calculate the sum of the elements of an array
     */
    function getSum(uint256[] memory array) internal pure returns (uint256) {
        if (array.length == 0) {
            return 0;
        }

        uint256 sum = 0;
        for (uint256 i = 0; i < array.length; i++) sum += array[i];
        return sum;
    }

    function toString(uint64[2] memory array) internal pure returns (string memory) {
        return string(abi.encodePacked('["', uint256(array[0]).toString(), '","', uint256(array[1]).toString(), '"]'));
    }

    function toCsv(uint256[] memory array) internal pure returns (string memory) {
        uint256 len = array.length;
        string memory result;
        for (uint256 i = 0; i < len; i++) {
            string memory s = array[i].toString();
            if (bytes(result).length == 0) result = s;
            else result = string(abi.encodePacked(result, ",", s));
        }

        return result;
    }

    function toCsv(string[] memory array) internal pure returns (string memory) {
        uint256 len = array.length;
        string memory result;
        for (uint256 i = 0; i < len; i++) {
            string memory s = string(abi.encodePacked('"', array[i], '"'));
            if (bytes(result).length == 0) result = s;
            else result = string(abi.encodePacked(result, ",", s));
        }

        return result;
    }
}
