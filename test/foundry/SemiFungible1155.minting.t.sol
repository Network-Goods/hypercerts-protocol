// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import { console2 } from "forge-std/console2.sol";
import { PRBTest } from "prb-test/PRBTest.sol";
import { StdCheats } from "forge-std/StdCheats.sol";
import { StdUtils } from "forge-std/StdUtils.sol";
import { SemiFungible1155Helper } from "./SemiFungibleHelper.sol";

/// @dev See the "Writing Tests" section in the Foundry Book if this is your first time with Forge.
/// https://book.getfoundry.sh/forge/writing-tests
contract SemiFungible1155Test is PRBTest, StdCheats, StdUtils, SemiFungible1155Helper {
    SemiFungible1155Helper internal semiFungible;
    string internal _uri;
    address internal alice;
    address internal bob;

    function setUp() public {
        semiFungible = new SemiFungible1155Helper();
        _uri = "ipfs://bafybeigdyrzt5sfp7udm7hu76uh7y26nf3efuylqabf3oclgtqy55fbzdi";
        alice = address(1);
        bob = address(2);
        startHoax(alice, 100 ether);
    }

    // UNHAPPY FLOWS

    function testMintZeroValue() public {
        vm.expectRevert(NotAllowed.selector);
        semiFungible.mintValue(alice, 0, _uri);
    }

    function testMintWithZeroInArray() public {
        uint256[] memory values = new uint256[](3);
        values[0] = 7000;
        values[1] = 3000;
        values[2] = 0;

        vm.expectRevert(NotAllowed.selector);
        semiFungible.mintValue(alice, values, _uri);
    }

    function testMintWithToLargeArray() public {
        uint256[] memory values = new uint256[](256);

        vm.expectRevert(ArraySize.selector);
        semiFungible.mintValue(alice, values, _uri);
    }

    // HAPPY MINTING

    function testMintValueSingle() public {
        uint256 _baseID = 1 << 128;

        // Transfer from 0x0 to 0x0 declares token baseID for claim
        // event TransferSingle
        // address indexed operator
        // address indexed from
        // address indexed to
        // uint256 id
        // uint256 value
        vm.expectEmit(true, true, true, true);
        emit TransferSingle(alice, address(0), alice, _baseID, 1);
        uint256 baseID = semiFungible.mintValue(alice, 10000, _uri);

        assertEq(baseID, _baseID);
        assertEq(semiFungible.creator(baseID), alice);
        assertEq(semiFungible.balanceOf(alice, baseID), 1);
        assertEq(semiFungible.totalUnits(baseID), 10000);
        assertEq(semiFungible.tokenValue(baseID + 0), 10000);
        assertEq(semiFungible.tokenValue(baseID + 1), 10000);
        assertEq(semiFungible.tokenValue(baseID + 2), 0);
    }

    function testFuzzMintValueSingle(uint256 value) public {
        vm.assume(value > 0);
        uint256 _baseID = 1 << 128;

        vm.expectEmit(true, true, true, true);
        emit TransferSingle(alice, address(0), alice, _baseID, 1);
        uint256 baseID = semiFungible.mintValue(alice, value, _uri);

        assertEq(baseID, _baseID);
        assertEq(semiFungible.creator(baseID), alice);
        assertEq(semiFungible.balanceOf(alice, baseID), 1);
        assertEq(semiFungible.totalUnits(baseID), value);
        assertEq(semiFungible.tokenValue(baseID + 0), value);
        assertEq(semiFungible.tokenValue(baseID + 1), value);
        assertEq(semiFungible.tokenValue(baseID + 2), 0);
    }

    function testMintValueArray() public {
        uint256[] memory values = new uint256[](3);
        values[0] = 7000;
        values[1] = 3000;
        values[2] = 5000;

        uint256 baseID = semiFungible.mintValue(alice, values, _uri);
        assertEq(semiFungible.balanceOf(alice, baseID), 1);
        assertEq(semiFungible.totalUnits(baseID), 15000);

        for (uint256 i = 0; i < values.length; i++) {
            assertEq(semiFungible.tokenValue(baseID + 1 + i), values[i]);
        }
    }

    function testFuzzMintValueArray(uint256[] memory values, address other) public {
        vm.assume(values.length > 0 && values.length < 254);
        vm.assume(semiFungible.noOverflow(values));
        vm.assume(semiFungible.noZeroes(values));
        vm.assume(other != address(1));

        semiFungible.mintValue(alice, values, _uri);

        uint256 baseID = 1 << 128;
        assertEq(semiFungible.balanceOf(alice, baseID), 1);
        assertEq(semiFungible.getSum(values), semiFungible.totalUnits(baseID));
        assertEq(semiFungible.balanceOf(other, baseID), 0);

        for (uint256 i = 0; i < values.length; i++) {
            assertEq(semiFungible.tokenValue(baseID + 1 + i), values[i]);
            assertEq(semiFungible.balanceOf(alice, baseID + 1 + i), 1);
            assertEq(semiFungible.balanceOf(other, baseID + 1 + i), 0);
        }
    }
}
