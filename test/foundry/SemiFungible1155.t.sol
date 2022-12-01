// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import { console2 } from "forge-std/console2.sol";
import { PRBTest } from "prb-test/PRBTest.sol";
import { StdCheats } from "forge-std/StdCheats.sol";
import { StdUtils } from "forge-std/StdUtils.sol";
import { SemiFungible1155 } from "../../src/SemiFungible1155.sol";

contract HelperContract is SemiFungible1155 {
    error FractionalBurn();
    error NotAllowed();

    function mintValue(address user, uint256 value, string memory uri) public {
        _mintValue(user, value, uri);
    }

    function mintValue(address user, uint256[] memory values, string memory uri) public {
        _mintValue(user, values, uri);
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
        for (uint256 i = 0; i < size; i++) _values[i] = baseID + i;
        return _values;
    }

    function getCount() public view returns (uint256) {
        return typeCounter;
    }
}

/// @dev See the "Writing Tests" section in the Foundry Book if this is your first time with Forge.
/// https://book.getfoundry.sh/forge/writing-tests
contract SemiFungible1155Test is PRBTest, StdCheats, StdUtils, HelperContract {
    HelperContract internal semiFungible;
    string internal _uri = "/ipfs/lalalalalalalalalallaallaa";

    function setUp() public {
        semiFungible = new HelperContract();
    }

    /// @dev Run Forge with `-vvvv` to see console logs.
    function testFailInitialize() public {
        semiFungible.__SemiFungible1155_init();
    }

    function testMintValueSingle() public {
        address alice = address(1);
        startHoax(alice, 100 ether);
        semiFungible.mintValue(alice, 10000, _uri);

        uint256 typeID = 1 << 128;

        assertEq(semiFungible.creators(typeID), alice);
        assertEq(semiFungible.balanceOf(alice, typeID), 10000);
        assertEq(semiFungible.totalSupply(typeID), 10000);
        assertEq(semiFungible.tokenValues(typeID + 0), 10000);
        assertEq(semiFungible.tokenValues(typeID + 1), 10000);
    }

    function testMintValueArray() public {
        address alice = address(1);
        startHoax(alice, 100 ether);

        uint256[] memory values = new uint256[](3);
        values[0] = 7000;
        values[1] = 3000;
        values[2] = 5000;

        semiFungible.mintValue(alice, values, _uri);

        uint256 typeID = 1 << 128;
        assertEq(semiFungible.balanceOf(alice, typeID), 15000);
        assertEq(semiFungible.totalSupply(typeID), 15000);
        assertEq(semiFungible.tokenValues(typeID + 1), 7000);
        assertEq(semiFungible.tokenValues(typeID + 2), 3000);
        assertEq(semiFungible.tokenValues(typeID + 3), 5000);
    }

    function testMintValueArrayFuzz(uint256[] memory values, address other) public {
        vm.assume(values.length > 0 && values.length < 254);
        vm.assume(semiFungible.noOverflow(values));
        vm.assume(other != address(1));
        address alice = address(1);
        hoax(alice, 100 ether);

        semiFungible.mintValue(alice, values, _uri);

        uint256 baseID = 1 << 128;
        uint256 balance = semiFungible.balanceOf(alice, baseID);
        assertEq(balance, semiFungible.getSum(values));
        assertEq(balance, semiFungible.totalSupply(baseID));

        assertEq(semiFungible.balanceOf(alice, baseID + values.length), values[values.length - 1]);

        uint256 balanceOther = semiFungible.balanceOf(other, baseID);
        assertEq(balanceOther, 0);
    }

    function testSplitValue() public {
        address alice = address(1);
        hoax(alice, 100 ether);

        uint256 baseID = 1 << 128;
        uint256 tokenID = baseID + 1;
        uint256[] memory values = new uint256[](2);
        values[0] = 7000;
        values[1] = 3000;

        semiFungible.mintValue(alice, 10000, _uri);
        semiFungible.splitValue(alice, tokenID, values);

        assertEq(semiFungible.balanceOf(alice, baseID), 10000);
        assertEq(semiFungible.totalSupply(baseID), 10000);

        assertEq(semiFungible.balanceOf(tokenID), 7000);
        assertEq(semiFungible.balanceOf(tokenID + 1), 3000);
    }

    function testSplitValueLarge() public {
        address alice = address(1);
        hoax(alice, 100 ether);

        uint256 baseID = 1 << 128;
        uint256 tokenID = baseID + 1;
        uint256 size = 100;
        uint256 value = 1000;
        uint256[] memory values = semiFungible.buildValues(size, value);
        uint256 totalValue = size * value;

        semiFungible.mintValue(alice, totalValue, _uri);

        semiFungible.splitValue(alice, tokenID, values);

        assertEq(semiFungible.balanceOf(alice, baseID), totalValue);
        assertEq(semiFungible.totalSupply(baseID), totalValue);

        assertEq(semiFungible.balanceOf(tokenID), value);
        assertEq(semiFungible.balanceOf(tokenID + 1), value);
        assertEq(semiFungible.balanceOf(tokenID + (size / 2)), value);
        assertEq(semiFungible.balanceOf(tokenID + (size - 1)), value);
    }

    function testMergeValue() public {
        address alice = address(1);
        hoax(alice, 100 ether);

        uint256 baseID = 1 << 128;
        uint256 size = 10;
        uint256 value = 2000;
        uint256[] memory values = semiFungible.buildValues(size, value);
        uint256 totalValue = size * value;

        uint256[] memory _ids = semiFungible.buildIDs(baseID + 1, size);

        semiFungible.mintValue(alice, values, _uri);

        assertEq(semiFungible.balanceOf(_ids[size - 1]), 2000);

        semiFungible.mergeValue(_ids);

        assertEq(semiFungible.balanceOf(alice, baseID), totalValue);
        assertEq(semiFungible.totalSupply(baseID), totalValue);

        for (uint256 id = 1; id < (_ids.length - 1); id++) {
            assertEq(semiFungible.balanceOf(baseID + id), 0);
        }

        assertEq(semiFungible.balanceOf(baseID + _ids.length), totalValue);
    }

    function testMergeValueFuzz(uint256 size) public {
        size = bound(size, 1, 253);

        address alice = address(1);

        uint256 baseID = 1 << 128;
        uint256 value = 2000;
        uint256[] memory values = semiFungible.buildValues(size, value);
        uint256 totalValue = size * value;

        uint256[] memory _ids = semiFungible.buildIDs(baseID + 1, size);

        semiFungible.mintValue(alice, values, _uri);
        semiFungible.mergeValue(_ids);

        assertEq(semiFungible.balanceOf(alice, baseID), totalValue);
        assertEq(semiFungible.totalSupply(baseID), totalValue);

        for (uint256 id = 1; id < _ids.length - 1; id++) {
            assertEq(semiFungible.balanceOf(baseID + id), 0);
        }

        assertEq(semiFungible.balanceOf(baseID + _ids.length), totalValue);
    }

    function testBurnValue() public {
        address alice = address(1);
        hoax(alice, 100 ether);

        semiFungible.mintValue(alice, 10000, _uri);

        uint256 baseID = 1 << 128;
        uint256[] memory values = new uint256[](2);
        values[0] = 7000;
        values[1] = 3000;

        semiFungible.mintValue(alice, values, _uri);

        uint256[] memory _ids = semiFungible.buildIDs(baseID + 1, values.length);

        vm.expectRevert(HelperContract.NotAllowed.selector);
        semiFungible.burnValue(alice, baseID);

        vm.expectRevert(HelperContract.FractionalBurn.selector);
        semiFungible.burnValue(alice, _ids[1]);

        semiFungible.mergeValue(_ids);

        semiFungible.burnValue(alice, _ids[_ids.length - 1]);

        assertEq(semiFungible.balanceOf(alice, baseID), 0);
        assertEq(semiFungible.totalSupply(baseID), 0);

        assertEq(semiFungible.balanceOf(baseID), 0);
        assertEq(semiFungible.balanceOf(baseID + 1), 0);
        assertEq(semiFungible.balanceOf(baseID + 2), 0);
    }
}
