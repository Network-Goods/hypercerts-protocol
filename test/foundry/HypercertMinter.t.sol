// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import { PRBTest } from "prb-test/PRBTest.sol";
import { StdCheats } from "forge-std/StdCheats.sol";
import { HypercertMinter } from "../../src/HypercertMinter.sol";
import { Merkle } from "murky/Merkle.sol";

/// @dev See the "Writing Tests" section in the Foundry Book if this is your first time with Forge.
/// https://book.getfoundry.sh/forge/writing-tests
contract HypercertMinterTest is PRBTest, StdCheats {
    Merkle internal merkle;
    HypercertMinter internal hypercertMinter;
    uint256[] internal fractions10;
    uint256[] internal fractions100;

    function setUp() public {
        merkle = new Merkle();
        hypercertMinter = new HypercertMinter();

        for (uint256 i = 0; i < fractions10.length; i++) {
            fractions10.push(100 * i + 1);
        }
        for (uint256 i = 0; i < fractions100.length; i++) {
            fractions100.push(100 * i + 1);
        }
    }

    /// @dev Run Forge with `-vvvv` to see console logs.
    function testFailInitialize() public {
        hypercertMinter.initialize();
    }

    function testName() public {
        assertEq(keccak256(abi.encodePacked(hypercertMinter.name())), keccak256("HypercertMinter"));
    }

    function testClaimSingleFraction(uint256) public {
        hypercertMinter.mintClaim(10000, "https://example.com/ipfsHash");
    }

    function testClaimTenFractions() public {
        hypercertMinter.mintClaimWithFractions(fractions10, "https://example.com/ipfsHash");
    }

    function testClaimHundredFractions() public {
        hypercertMinter.mintClaimWithFractions(fractions100, "https://example.com/ipfsHash");
    }

    function testClaimHundredFractionsLarge() public {
        hypercertMinter.mintClaimWithFractions(fractions100, "https://example.com/ipfsHash");
    }

    function onERC1155Received(address, address, uint256, uint256, bytes memory) public pure returns (bytes4) {
        return this.onERC1155Received.selector;
    }
}
