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

    // UNHAPPY FLOWS

    function testFailMintZeroValue() public {
        startHoax(alice, 100 ether);

        // revert NotAllowed()
        semiFungible.mintValue(alice, 0, _uri);
    }

    function testFailMintValueWithZeroInArray() public {
        startHoax(alice, 100 ether);

        uint256[] memory values = new uint256[](3);
        values[0] = 7000;
        values[1] = 3000;
        values[2] = 0;

        // revert NotAllowed()
        semiFungible.mintValue(alice, values, _uri);
    }

    // HAPPY MINTING

    function testMintValueSingle() public {
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
        vm.assume(semiFungible.noZeroes(values));
        vm.assume(other != address(1));
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
}
