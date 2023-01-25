// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import { console2 } from "forge-std/console2.sol";
import { PRBTest } from "prb-test/PRBTest.sol";
import { StdCheats } from "forge-std/StdCheats.sol";
import { StdUtils } from "forge-std/StdUtils.sol";
import { SemiFungible1155Helper } from "./SemiFungibleHelper.sol";

/// @dev See the "Writing Tests" section in the Foundry Book if this is your first time with Forge.
/// https://book.getfoundry.sh/forge/writing-tests
contract SemiFungible1155BurnTest is PRBTest, StdCheats, StdUtils, SemiFungible1155Helper {
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

    function testBurnValue() public {
        uint256 baseID = 1 << 128;

        uint256 size = 20;
        uint256 value = 2000;
        uint256[] memory values = semiFungible.buildValues(size, value);
        uint256[] memory tokenIDs = semiFungible.buildIDs(baseID, size);

        startHoax(alice, 100 ether);

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

        semiFungible.validateNotOwnerNoBalanceNoUnits(baseID, alice);

        for (uint256 i = 0; i < tokenIDs.length; i++) {
            semiFungible.validateNotOwnerNoBalanceNoUnits(tokenIDs[i], alice);
        }
    }
}
