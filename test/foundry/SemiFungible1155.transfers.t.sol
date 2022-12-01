// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import { console2 } from "forge-std/console2.sol";
import { PRBTest } from "prb-test/PRBTest.sol";
import { StdCheats } from "forge-std/StdCheats.sol";
import { StdUtils } from "forge-std/StdUtils.sol";
import { SemiFungible1155 } from "../../src/SemiFungible1155.sol";

contract HelperContract is SemiFungible1155 {
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

    function isContract(address account) public view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }
}

/// @dev See the "Writing Tests" section in the Foundry Book if this is your first time with Forge.
/// https://book.getfoundry.sh/forge/writing-tests
contract SemiFungible1155TransferTest is PRBTest, StdCheats, StdUtils {
    HelperContract internal semiFungible;
    string internal _uri = "/ipfs/lalalalalalalalalallaallaa";

    function setUp() public {
        semiFungible = new HelperContract();
    }

    function testTransferFull() public {
        address alice = address(1);
        address bob = address(42);

        hoax(alice, 100 ether);

        uint256 baseID = 1 << 128;
        uint256 tokenID = baseID + 1;

        semiFungible.mintValue(alice, 10000, _uri);

        assertEq(semiFungible.balanceOf(alice, baseID), 10000);
        assertEq(semiFungible.balanceOf(alice, tokenID), 10000);

        assertEq(semiFungible.balanceOf(bob, baseID), 0);
        assertEq(semiFungible.balanceOf(bob, tokenID), 0);

        vm.prank(alice);
        semiFungible.safeTransferFrom(alice, bob, tokenID, 1, "");

        // Updates tokenFraction value for (new) owner
        assertEq(semiFungible.balanceOf(alice, baseID), 0);
        assertEq(semiFungible.balanceOf(alice, tokenID), 0);

        // Updates token ownership
        assertEq(semiFungible.balanceOf(bob, baseID), 10000);
        assertEq(semiFungible.balanceOf(bob, tokenID), 10000);
    }

    function testTransferFullFuzz(address from, address to, uint256 amount) public {
        vm.assume(from != to && from != address(0) && to != address(0));
        vm.assume(!semiFungible.isContract(from) && !semiFungible.isContract(to));

        hoax(from, 100 ether);

        uint256 baseID = 1 << 128;
        uint256 tokenID = baseID + 1;

        semiFungible.mintValue(from, amount, _uri);

        assertEq(semiFungible.balanceOf(from, baseID), amount);
        assertEq(semiFungible.balanceOf(from, tokenID), amount);

        assertEq(semiFungible.balanceOf(to, baseID), 0);
        assertEq(semiFungible.balanceOf(to, tokenID), 0);

        vm.prank(from);
        semiFungible.safeTransferFrom(from, to, tokenID, 1, "");

        // Updates tokenFraction value for (new) owner
        assertEq(semiFungible.balanceOf(from, baseID), 0);
        assertEq(semiFungible.balanceOf(from, tokenID), 0);

        // Updates token ownership
        assertEq(semiFungible.balanceOf(to, baseID), amount);
        assertEq(semiFungible.balanceOf(to, tokenID), amount);
    }

    function testTransferFraction() public {
        address alice = address(1);
        address bob = address(42);

        hoax(alice, 100 ether);

        uint256 baseID = 1 << 128;
        uint256 tokenID = baseID + 1;
        uint256 size = 20;
        uint256 value = 2000;
        uint256 totalValue = size * value;
        uint256[] memory values = semiFungible.buildValues(size, value);
        uint256[] memory _ids = semiFungible.buildIDs(baseID, size);

        semiFungible.mintValue(alice, values, _uri);

        assertEq(semiFungible.balanceOf(alice, baseID), totalValue);
        assertEq(semiFungible.balanceOf(alice, tokenID), value);

        assertEq(semiFungible.balanceOf(bob, baseID), 0);
        assertEq(semiFungible.balanceOf(bob, tokenID), 0);

        vm.prank(alice);
        semiFungible.safeTransferFrom(alice, bob, _ids[1], 1, "");

        // Updates tokenFraction value for (new) owner
        assertEq(semiFungible.balanceOf(alice, baseID), totalValue - value);
        assertEq(semiFungible.balanceOf(alice, _ids[1]), 0);

        // Updates token ownership
        assertEq(semiFungible.balanceOf(bob, baseID), value);
        assertEq(semiFungible.balanceOf(bob, _ids[1]), value);
    }

    function testTransferFractionFuzz(address from, address to, uint256 size) public {
        vm.assume(from != to && from != address(0) && to != address(0));
        vm.assume(!semiFungible.isContract(from) && !semiFungible.isContract(to));
        size = bound(size, 1, 253);

        hoax(from, 100 ether);

        uint256 baseID = 1 << 128;
        uint256 tokenID = baseID + 1;
        uint256 value = 2000;
        uint256 totalValue = size * value;
        uint256[] memory values = semiFungible.buildValues(size, value);
        uint256[] memory _ids = semiFungible.buildIDs(tokenID, size);

        semiFungible.mintValue(from, values, _uri);

        assertEq(semiFungible.balanceOf(from, baseID), totalValue);
        for (uint256 i = 1; i < (_ids.length - 1); i++) {
            assertEq(semiFungible.balanceOf(from, _ids[i]), value);
        }

        assertEq(semiFungible.balanceOf(to, baseID), 0);
        for (uint256 i = 1; i < (_ids.length - 1); i++) {
            assertEq(semiFungible.balanceOf(to, _ids[i]), 0);
        }

        vm.prank(from);
        semiFungible.safeTransferFrom(from, to, _ids[size - 1], 1, "");

        // // Updates tokenFraction value for (new) owner
        assertEq(semiFungible.balanceOf(from, baseID), totalValue - value);
        assertEq(semiFungible.balanceOf(from, _ids[size - 1]), 0);

        // // Updates token ownership
        assertEq(semiFungible.balanceOf(to, baseID), value);
        assertEq(semiFungible.balanceOf(to, _ids[size - 1]), value);
    }
}
