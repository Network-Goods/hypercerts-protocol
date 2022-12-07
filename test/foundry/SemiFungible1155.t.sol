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
    }

    /// @dev Run Forge with `-vvvv` to see console logs.
    function testFailInitialize() public {
        semiFungible.__SemiFungible1155_init();
    }

    function testSplitValue() public {
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
        hoax(alice, 100 ether);

        uint256 baseID = 1 << 128;
        uint256 size = 10;
        uint256 value = 2000;
        uint256[] memory values = semiFungible.buildValues(size, value);
        uint256 totalValue = size * value;

        uint256[] memory _ids = semiFungible.buildIDs(baseID, size);

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

        uint256 baseID = 1 << 128;
        uint256 value = 2000;
        uint256[] memory values = semiFungible.buildValues(size, value);
        uint256 totalValue = size * value;

        uint256[] memory tokenIDs = semiFungible.buildIDs(baseID, size);

        semiFungible.mintValue(alice, values, _uri);
        semiFungible.mergeValue(tokenIDs);

        assertEq(semiFungible.balanceOf(alice, baseID), totalValue);
        assertEq(semiFungible.totalSupply(baseID), totalValue);

        for (uint256 i = 1; i < tokenIDs.length - 1; i++) {
            assertEq(semiFungible.balanceOf(tokenIDs[i]), 0);
        }

        assertEq(semiFungible.balanceOf(tokenIDs[tokenIDs.length - 1]), totalValue);
    }

    function testBurnValue() public {
        hoax(alice, 100 ether);

        uint256 baseID = 1 << 128;

        uint256 size = 20;
        uint256 value = 2000;
        uint256[] memory values = semiFungible.buildValues(size, value);
        uint256[] memory tokenIDs = semiFungible.buildIDs(baseID, size);

        semiFungible.mintValue(alice, values, _uri);

        //TODO No burn of base token?
        vm.expectRevert(SemiFungible1155Helper.NotAllowed.selector);
        semiFungible.burnValue(alice, baseID);

        // No fractional burn
        vm.expectRevert(SemiFungible1155Helper.FractionalBurn.selector);
        semiFungible.burnValue(alice, tokenIDs[1]);

        // Need to merge to only allow burn of full token
        semiFungible.mergeValue(tokenIDs);

        // Burn merged token
        semiFungible.burnValue(alice, tokenIDs[tokenIDs.length - 1]);

        assertEq(semiFungible.balanceOf(alice, baseID), 0);
        assertEq(semiFungible.totalSupply(baseID), 0);

        assertEq(semiFungible.balanceOf(baseID), 0);

        for (uint256 i = 0; i < tokenIDs.length; i++) {
            assertEq(semiFungible.balanceOf(tokenIDs[i]), 0);
        }
    }
}
