// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;
import { SemiFungible1155 } from "../../src/SemiFungible1155.sol";

contract SemiFungible1155Helper is SemiFungible1155 {
    error FractionalBurn();
    error NotAllowed();
    error NotApprovedOrOwner();
    error ArraySize();

    function creator(uint256 tokenID) public view returns (address _creator) {
        _creator = creators[tokenID];
    }

    function tokenValue(uint256 tokenID) public view returns (uint256 value) {
        value = tokenValues[tokenID];
    }

    function mintValue(address user, uint256 value, string memory uri) public returns (uint256 tokenID) {
        return _mintValue(user, value, uri);
    }

    function mintValue(address user, uint256[] memory values, string memory uri) public returns (uint256 tokenID) {
        return _mintValue(user, values, uri);
    }

    function noOverflow(uint256[] memory values) public pure returns (bool) {
        uint256 total;
        for (uint256 i = 0; i < values.length; i++) {
            uint256 newTotal;
            unchecked {
                newTotal = total + values[i];
                if (newTotal < total) {
                    return false;
                }
                total = newTotal;
            }
        }
        return true;
    }

    function noZeroes(uint256[] memory values) public pure returns (bool) {
        for (uint256 i = 0; i < values.length; i++) {
            if (values[i] == 0) return false;
        }
        return true;
    }

    function getSum(uint256[] memory array) public pure returns (uint256 sum) {
        if (array.length == 0) {
            return 0;
        }
        sum = 0;
        for (uint256 i = 0; i < array.length; i++) sum += array[i];
    }

    function buildValues(uint256 size, uint256 base) public pure returns (uint256[] memory) {
        uint256[] memory _values = new uint256[](size);
        for (uint256 i = 0; i < size; i++) _values[i] = base;
        return _values;
    }

    function buildIDs(uint256 baseID, uint256 size) public pure returns (uint256[] memory) {
        uint256[] memory _values = new uint256[](size);
        for (uint256 i = 0; i < size; i++) _values[i] = baseID + i + 1;
        return _values;
    }

    function getCount() public view returns (uint256) {
        return typeCounter;
    }

    function isContract(address account) public view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }
}
