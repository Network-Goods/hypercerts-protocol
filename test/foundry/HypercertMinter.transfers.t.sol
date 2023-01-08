// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import { console2 } from "forge-std/console2.sol";
import { StdCheats } from "forge-std/StdCheats.sol";
import { StdUtils } from "forge-std/StdUtils.sol";
import { PRBTest } from "prb-test/PRBTest.sol";
import { HypercertMinter, TransfersNotAllowed } from "../../src/HypercertMinter.sol";
import { TransferRestrictions } from "../../src/interfaces/IHypercertToken.sol";

/// @dev Testing transfer restrictions on hypercerts
contract HypercertMinterTransferTest is PRBTest, StdCheats, StdUtils {
    HypercertMinter internal hypercertMinter;
    string internal _uri;
    uint256 _units;
    uint256 baseID;
    uint128 tokenIndex;
    uint256 tokenID;
    address internal alice;
    address internal bob;

    function setUp() public {
        hypercertMinter = new HypercertMinter();
        _uri = "ipfs://bafybeigdyrzt5sfp7udm7hu76uh7y26nf3efuylqabf3oclgtqy55fbzdi";
        _units = 10000;
        baseID = 1 << 128;
        tokenIndex = 1;
        tokenID = baseID + tokenIndex;
        alice = address(1);
        bob = address(2);
    }

    function testTransferAllowAll() public {
        // Alice creates a hypercert
        vm.prank(alice);
        hypercertMinter.mintClaim(_units, _uri, TransferRestrictions.AllowAll);
        assertEq(hypercertMinter.balanceOf(alice, tokenID), 1);
        assertEq(hypercertMinter.balanceOf(bob, tokenID), 0);

        // Alice transfers ownership of hypercert to Bob
        vm.prank(alice);
        hypercertMinter.safeTransferFrom(alice, bob, tokenID, 1, "");
        assertEq(hypercertMinter.balanceOf(alice, tokenID), 0);
        assertEq(hypercertMinter.balanceOf(bob, tokenID), 1);

        // Bob transfers back it back to Alice
        vm.prank(bob);
        hypercertMinter.safeTransferFrom(bob, alice, tokenID, 1, "");
        assertEq(hypercertMinter.balanceOf(alice, tokenID), 1);
        assertEq(hypercertMinter.balanceOf(bob, tokenID), 0);
    }

    function testTransferDisallowAll() public {
        // Alice creates a hypercert
        vm.prank(alice);
        hypercertMinter.mintClaim(_units, _uri, TransferRestrictions.DisallowAll);
        assertEq(hypercertMinter.balanceOf(alice, tokenID), 1);
        assertEq(hypercertMinter.balanceOf(bob, tokenID), 0);

        // Alice fails to transfer token
        vm.prank(alice);
        vm.expectRevert(TransfersNotAllowed.selector);
        hypercertMinter.safeTransferFrom(alice, bob, tokenID, 1, "");
        assertEq(hypercertMinter.balanceOf(alice, tokenID), 1);
        assertEq(hypercertMinter.balanceOf(bob, tokenID), 0);
    }

    function testTransferFromCreatorOnly() public {
        // Alice creates a hypercert
        vm.prank(alice);
        hypercertMinter.mintClaim(_units, _uri, TransferRestrictions.FromCreatorOnly);
        assertEq(hypercertMinter.balanceOf(alice, tokenID), 1);
        assertEq(hypercertMinter.balanceOf(bob, tokenID), 0);

        // Alice transfers ownership of hypercert to Bob
        vm.prank(alice);
        hypercertMinter.safeTransferFrom(alice, bob, tokenID, 1, "");
        assertEq(hypercertMinter.balanceOf(alice, tokenID), 0);
        assertEq(hypercertMinter.balanceOf(bob, tokenID), 1);

        // Bob fails to transfer token
        vm.prank(bob);
        vm.expectRevert(TransfersNotAllowed.selector);
        hypercertMinter.safeTransferFrom(bob, alice, tokenID, 1, "");
        assertEq(hypercertMinter.balanceOf(alice, tokenID), 0);
        assertEq(hypercertMinter.balanceOf(bob, tokenID), 1);
    }
}
