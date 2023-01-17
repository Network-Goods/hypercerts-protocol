// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import { console2 } from "forge-std/console2.sol";
import { PRBTest } from "prb-test/PRBTest.sol";
import { StdCheats } from "forge-std/StdCheats.sol";
import { HypercertMinter } from "../../src/HypercertMinter.sol";
import { Merkle } from "murky/Merkle.sol";

// forge test -vv --match-path test/foundry/PerformanceTesting.t.sol

contract PerformanceTestHelper is Merkle {
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

    function generateData(address account, uint256 size, uint256 value) public pure returns (bytes32[] memory data) {
        data = new bytes32[](size);
        for (uint256 i = 0; i < size; i++) {
            data[i] = keccak256(bytes.concat(keccak256(abi.encode(account, value))));
        }
    }

    function isContract(address _addr) internal view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }
}

/// @dev See the "Writing Tests" section in the Foundry Book if this is your first time with Forge.
/// https://book.getfoundry.sh/forge/writing-tests
contract PerformanceTesting is PRBTest, StdCheats, PerformanceTestHelper {
    HypercertMinter internal hypercertMinter;
    string _uri = "https://example.com/ipfsHash";
    bytes32 root = bytes32(bytes.concat("f1ef5e66fa78313ec3d3617a44c21a9061f1c87437f512625a50a5a29335a647"));
    bytes32 rootHash;
    bytes32[] proof;
    address alice;

    function setUp() public {
        alice = address(1);
        hypercertMinter = new HypercertMinter();
        bytes32[] memory data = generateData(alice, 12, 200000);
        rootHash = getRoot(data);
        proof = getProof(data, 6);

        startHoax(alice, 10 ether);
        hypercertMinter.createAllowlist(200000, rootHash, _uri);
    }

    /// @dev Run Forge with `-vvvv` to see console logs.
    function testFail() public {
        hypercertMinter.initialize();
    }

    function testName() public {
        assertEq(keccak256(abi.encodePacked(hypercertMinter.name())), keccak256("HypercertMinter"));
    }

    // Mint Hypercert with 1 fraction
    function testClaimSingleFraction() public {
        hypercertMinter.mintClaim(10000, _uri);
    }

    function testClaimSingleFractionFuzz(address account, uint256 units) public {
        vm.assume(units > 0);
        vm.assume(account != address(0) && account != address(this) && account != address(hypercertMinter));

        changePrank(account);
        hypercertMinter.mintClaim(units, _uri);
    }

    // Mint Hypercert with multiple fractions

    function testClaimTwoFractions() public {
        uint256[] memory fractions = buildFractions(2);
        uint256 totalUnits = getSum(fractions);

        hypercertMinter.mintClaimWithFractions(totalUnits, fractions, _uri);
    }

    function testClaimHundredFractions() public {
        uint256[] memory fractions = buildFractions(100);
        uint256 totalUnits = getSum(fractions);

        hypercertMinter.mintClaimWithFractions(totalUnits, fractions, _uri);
    }

    function testClaimFractionsFuzz(uint256[] memory fractions) public {
        vm.assume(noOverflow(fractions));
        vm.assume(noZeroes(fractions));
        vm.assume(fractions.length > 0 && fractions.length < 253);
        uint256 totalUnits = getSum(fractions);

        hypercertMinter.mintClaimWithFractions(totalUnits, fractions, _uri);
    }

    // Store allowlist and reserve Hypercert ID
    function testCreateAllowlist() public {
        hypercertMinter.createAllowlist(10000, root, _uri);
    }

    function testCreateAllowlistFuzz(address account, uint256 units) public {
        vm.assume(units > 0);
        vm.assume(!isContract(account) && account != address(0));

        changePrank(account);
        hypercertMinter.createAllowlist(units, root, _uri);
    }

    // Mint claim from allowlist
    function testClaimAllowlistFraction() public {
        changePrank(alice);
        hypercertMinter.mintClaimFromAllowlist(proof, 340282366920938463463374607431768211456, 200000);
    }
}
