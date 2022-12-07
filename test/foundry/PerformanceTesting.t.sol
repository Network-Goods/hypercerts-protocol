// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import { console2 } from "forge-std/console2.sol";
import { PRBTest } from "prb-test/PRBTest.sol";
import { StdCheats } from "forge-std/StdCheats.sol";
import { HypercertMinter } from "../../src/HypercertMinter.sol";

contract HelperContract {
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

    function noZeroes(uint256[] memory values) public pure returns (bool) {
        for (uint256 i = 0; i < values.length; i++) {
            if (values[i] == 0) return false;
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

    function buildFractions(uint256 size) public pure returns (uint256[] memory) {
        uint256[] memory fractions = new uint256[](size);
        for (uint256 i = 0; i < size; i++) {
            fractions[i] = 100 * i + 1;
        }
        return fractions;
    }
}

/// @dev See the "Writing Tests" section in the Foundry Book if this is your first time with Forge.
/// https://book.getfoundry.sh/forge/writing-tests
contract PerformanceTesting is PRBTest, StdCheats, HelperContract {
    HypercertMinter internal hypercertMinter;

    function setUp() public {
        hypercertMinter = new HypercertMinter();
    }

    /// @dev Run Forge with `-vvvv` to see console logs.
    function testFail() public {
        hypercertMinter.initialize();
    }

    function testName() public {
        assertEq(keccak256(abi.encodePacked(hypercertMinter.name())), keccak256("HypercertMinter"));
    }

    function testClaimSingleFraction() public {
        vm.prank(address(1));
        hypercertMinter.mintClaim(10000, "https://example.com/ipfsHash");
    }

    function testClaimTwoFractions() public {
        uint256[] memory fractions = buildFractions(2);

        vm.prank(address(1));
        hypercertMinter.mintClaimWithFractions(fractions, "https://example.com/ipfsHash");
    }

    function testClaimHundredFractions() public {
        uint256[] memory fractions = buildFractions(100);

        vm.prank(address(1));
        hypercertMinter.mintClaimWithFractions(fractions, "https://example.com/ipfsHash");
    }

    function testClaimFractionsFuzz(uint256[] memory fractions) public {
        vm.assume(noOverflow(fractions));
        vm.assume(noZeroes(fractions));
        vm.assume(fractions.length > 0 && fractions.length < 253);

        vm.prank(address(1));
        hypercertMinter.mintClaimWithFractions(fractions, "https://example.com/ipfsHash");
    }
}
