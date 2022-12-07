// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import { console2 } from "forge-std/console2.sol";
import { PRBTest } from "prb-test/PRBTest.sol";
import { StdCheats } from "forge-std/StdCheats.sol";
import { StdUtils } from "forge-std/StdUtils.sol";
import { SemiFungible1155Helper } from "./SemiFungibleHelper.sol";

/// @dev See the "Writing Tests" section in the Foundry Book if this is your first time with Forge.
/// https://book.getfoundry.sh/forge/writing-tests
contract SemiFungible1155TransferTest is PRBTest, StdCheats, StdUtils {
    SemiFungible1155Helper internal semiFungible;
    string internal _uri;
    address internal alice;
    address internal bob;

    function setUp() public {
        semiFungible = new SemiFungible1155Helper();
        _uri = "ipfs://bafybeigdyrzt5sfp7udm7hu76uh7y26nf3efuylqabf3oclgtqy55fbzdi";
        alice = address(1);
        bob = address(2);
        hoax(alice, 100 ether);
    }

    // UNHAPPY PATHS
    function testFailTransferTypeIDToken() public {
        vm.startPrank(alice);
        semiFungible.mintValue(alice, 10000, _uri);

        //NotApprovedOrOWner, since no owner
        semiFungible.safeTransferFrom(alice, bob, 1 << 128, 1, "");
    }

    function testFailTransferNonExistingFractionToken() public {
        vm.startPrank(alice);
        semiFungible.mintValue(alice, 10000, _uri);

        //NotApprovedOrOWner, since no owner
        semiFungible.safeTransferFrom(alice, bob, 1 << (128 + 2), 1, "");
    }

    function testTransferNonExistingTokenWithValue() public {
        vm.startPrank(alice);

        uint256 baseID = 1 << 128;
        uint128 tokenID = 1;

        // Pass because zero-value in call
        //TODO think about UX, cheaper on gas for calls containing value
        semiFungible.safeTransferFrom(alice, bob, baseID + tokenID, 1, "");
    }

    function testTransferNonExistingFungibleTokenTokenNoValue() public {
        vm.startPrank(alice);

        uint256 baseID = 1 << 128;
        uint128 tokenID = 1;

        // Pass because zero-value in call
        //TODO think about UX, cheaper on gas for calls containing value
        semiFungible.safeTransferFrom(alice, bob, baseID + tokenID, 0, "");
    }

    // FULL TOKENS

    function testTransferFullToken() public {
        uint256 baseID = 1 << 128;
        uint128 tokenID = 1;

        semiFungible.mintValue(alice, 10000, _uri);

        assertEq(semiFungible.balanceOf(alice, baseID), 10000);
        assertEq(semiFungible.balanceOf(alice, baseID + tokenID), 10000);

        assertEq(semiFungible.balanceOf(bob, baseID), 0);
        assertEq(semiFungible.balanceOf(bob, baseID + tokenID), 0);

        vm.startPrank(alice);

        // Bloack transfer ownership of impact claim 'data'
        vm.expectRevert(SemiFungible1155Helper.NotAllowed.selector);
        semiFungible.safeTransferFrom(alice, bob, baseID, 1, "");

        // Transfer ownership of hypercert
        semiFungible.safeTransferFrom(alice, bob, baseID + tokenID, 1, "");

        // Updates tokenFraction value for (new) owner
        assertEq(semiFungible.balanceOf(alice, baseID), 0);
        assertEq(semiFungible.balanceOf(alice, baseID + tokenID), 0);

        // Updates token ownership
        assertEq(semiFungible.balanceOf(bob, baseID), 10000);
        assertEq(semiFungible.balanceOf(bob, baseID + tokenID), 10000);
    }

    function testFuzzTransferFullToken(address from, address to, uint256 amount) public {
        vm.assume(amount > 0);
        vm.assume(from != to && from != address(0) && to != address(0));
        vm.assume(!semiFungible.isContract(from) && !semiFungible.isContract(to));

        startHoax(from, 100 ether);

        uint256 baseID = 1 << 128;
        uint128 tokenID = 1;

        semiFungible.mintValue(from, amount, _uri);

        assertEq(semiFungible.balanceOf(from, baseID), amount);
        assertEq(semiFungible.balanceOf(from, baseID + tokenID), amount);

        assertEq(semiFungible.balanceOf(to, baseID), 0);
        assertEq(semiFungible.balanceOf(to, baseID + tokenID), 0);

        semiFungible.safeTransferFrom(from, to, baseID + tokenID, 1, "");

        // Updates tokenFraction value for (new) owner
        assertEq(semiFungible.balanceOf(from, baseID), 0);
        assertEq(semiFungible.balanceOf(from, baseID + tokenID), 0);

        // Updates token ownership
        assertEq(semiFungible.balanceOf(to, baseID), amount);
        assertEq(semiFungible.balanceOf(to, baseID + tokenID), amount);
    }

    // FRACTIONS

    function testTransferFraction() public {
        hoax(alice, 100 ether);

        uint256 baseID = 1 << 128;
        uint128 tokenID = 1;

        uint256 size = 20;
        uint256 value = 2000;
        uint256 totalValue = size * value;
        uint256[] memory values = semiFungible.buildValues(size, value);
        uint256[] memory _ids = semiFungible.buildIDs(baseID, size);

        semiFungible.mintValue(alice, values, _uri);

        assertEq(semiFungible.balanceOf(alice, baseID), totalValue);
        assertEq(semiFungible.balanceOf(alice, baseID + tokenID), value);

        assertEq(semiFungible.balanceOf(bob, baseID), 0);
        assertEq(semiFungible.balanceOf(bob, baseID + tokenID), 0);

        vm.prank(alice);
        semiFungible.safeTransferFrom(alice, bob, _ids[1], 1, "");

        // Updates tokenFraction value for (new) owner
        assertEq(semiFungible.balanceOf(alice, baseID), totalValue - value);
        assertEq(semiFungible.balanceOf(alice, _ids[1]), 0);

        // Updates token ownership
        assertEq(semiFungible.balanceOf(bob, baseID), value);
        assertEq(semiFungible.balanceOf(bob, _ids[1]), value);
    }

    function testFuzzTransferFraction(address from, address to, uint256 size) public {
        vm.assume(from != to && from != address(0) && to != address(0));
        vm.assume(!semiFungible.isContract(from) && !semiFungible.isContract(to));
        size = bound(size, 1, 253);

        startHoax(from, 100 ether);

        uint256 baseID = 1 << 128;

        uint256 value = 2000;
        uint256 totalValue = size * value;
        uint256[] memory values = semiFungible.buildValues(size, value);
        uint256[] memory _ids = semiFungible.buildIDs(baseID, size);

        semiFungible.mintValue(from, values, _uri);

        assertEq(semiFungible.balanceOf(from, baseID), totalValue);
        for (uint256 i = 0; i < _ids.length; i++) {
            assertEq(semiFungible.balanceOf(from, _ids[i]), value);
        }

        assertEq(semiFungible.balanceOf(to, baseID), 0);
        for (uint256 i = 0; i < _ids.length; i++) {
            assertEq(semiFungible.balanceOf(to, _ids[i]), 0);
        }

        semiFungible.safeTransferFrom(from, to, _ids[size - 1], 1, "");

        // // Updates tokenFraction value for (new) owner
        assertEq(semiFungible.balanceOf(from, baseID), totalValue - value);
        assertEq(semiFungible.balanceOf(from, _ids[size - 1]), 0);

        // // Updates token ownership
        assertEq(semiFungible.balanceOf(to, baseID), value);
        assertEq(semiFungible.balanceOf(to, _ids[size - 1]), value);
    }
}
