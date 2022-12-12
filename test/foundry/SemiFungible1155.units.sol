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

    // FULL TOKENS

    function testUnitsSingleFraction() public {
        uint256 baseID = 1 << 128;
        uint128 tokenID = 1;

        vm.startPrank(alice);

        semiFungible.mintValue(alice, 10000, _uri);

        assertEq(semiFungible.balanceOf(alice, baseID), 1);
        assertEq(semiFungible.balanceOf(alice, baseID + tokenID), 1);

        assertEq(semiFungible.balanceOf(bob, baseID), 0);
        assertEq(semiFungible.balanceOf(bob, baseID + tokenID), 0);

        assertEq(semiFungible.unitsOf(baseID), 10_000);

        assertEq(semiFungible.unitsOf(alice, baseID), 10_000);
        assertEq(semiFungible.unitsOf(alice, baseID + tokenID), 10_000);

        assertEq(semiFungible.unitsOf(bob, baseID), 0);
        assertEq(semiFungible.unitsOf(bob, baseID + tokenID), 0);

        // All tokens have value/supply of 1
        vm.expectRevert(SemiFungible1155Helper.NotAllowed.selector);
        semiFungible.safeTransferFrom(alice, bob, baseID, 10_000, "");

        // Block 'regular' transfer of base type ID token
        vm.expectRevert(SemiFungible1155Helper.NotAllowed.selector);
        semiFungible.safeTransferFrom(alice, bob, baseID, 1, "");

        // Transfer ownership of fractional token
        semiFungible.safeTransferFrom(alice, bob, baseID + tokenID, 1, "");

        assertEq(semiFungible.balanceOf(alice, baseID), 1);
        assertEq(semiFungible.balanceOf(alice, baseID + tokenID), 0);

        assertEq(semiFungible.balanceOf(bob, baseID), 0);
        assertEq(semiFungible.balanceOf(bob, baseID + tokenID), 1);

        assertEq(semiFungible.unitsOf(baseID), 10_000);

        assertEq(semiFungible.unitsOf(alice, baseID), 0);
        assertEq(semiFungible.unitsOf(alice, baseID + tokenID), 0);

        assertEq(semiFungible.unitsOf(bob, baseID), 10_000);
        assertEq(semiFungible.unitsOf(bob, baseID + tokenID), 10_000);
    }

    function testUnitsMultipleFractions() public {
        uint256 baseID = 1 << 128;

        uint256 size = 20;
        uint256 value = 2000;
        uint256 totalValue = size * value;
        uint256[] memory values = semiFungible.buildValues(size, value);
        uint256[] memory _ids = semiFungible.buildIDs(baseID, size);

        vm.startPrank(alice);

        semiFungible.mintValue(alice, values, _uri);

        assertEq(semiFungible.balanceOf(alice, baseID), 1);
        assertEq(semiFungible.balanceOf(bob, baseID), 0);
        assertEq(semiFungible.unitsOf(baseID), totalValue);
        assertEq(semiFungible.unitsOf(alice, baseID), totalValue);
        assertEq(semiFungible.unitsOf(bob, baseID), 0);

        for (uint256 i = 0; i < _ids.length; i++) {
            assertEq(semiFungible.balanceOf(alice, _ids[i]), 1);
            assertEq(semiFungible.balanceOf(bob, _ids[i]), 0);
            assertEq(semiFungible.unitsOf(alice, _ids[i]), value);
            assertEq(semiFungible.unitsOf(bob, _ids[i]), 0);
        }
    }
}
