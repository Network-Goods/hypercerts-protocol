// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import { console2 } from "forge-std/console2.sol";
import { PRBTest } from "prb-test/PRBTest.sol";
import { StdCheats } from "forge-std/StdCheats.sol";
import { StdUtils } from "forge-std/StdUtils.sol";

import { AllowlistMinter } from "../../src/AllowlistMinter.sol";
import { Merkle } from "murky/Merkle.sol";

contract MerkleHelper is AllowlistMinter, Merkle {
    function generateData(uint256 size, uint256 value) public view returns (bytes32[] memory data) {
        data = new bytes32[](size);
        for (uint256 i = 0; i < size; i++) {
            data[i] = keccak256(bytes.concat(keccak256(abi.encodePacked(msg.sender, value))));
        }
    }

    function processClaim(bytes32[] calldata proof, uint256 claimID, uint256 amount) public returns (bool processed) {
        _processClaim(proof, claimID, amount);
        processed = true;
    }

    function createAllowlist(uint256 claimID, bytes32 root) public returns (bool created) {
        _createAllowlist(claimID, root);
        created = true;
    }
}

/// @dev See the "Writing Tests" section in the Foundry Book if this is your first time with Forge.
/// https://book.getfoundry.sh/forge/writing-tests
contract AllowlistTest is PRBTest, StdCheats, StdUtils {
    event WorkScopeAdded(bytes32 indexed id, string indexed text);
    event RightAdded(bytes32 indexed id, string indexed text);
    event ImpactScopeAdded(bytes32 indexed id, string indexed text);
    MerkleHelper internal merkle;

    function setUp() public {
        merkle = new MerkleHelper();
    }

    function testBasicAllowlist() public {
        bytes32[] memory data = merkle.generateData(4, 10_000);
        bytes32 root = merkle.getRoot(data);
        bytes32[] memory proof = merkle.getProof(data, 2);

        uint256 claimID = 1;

        merkle.createAllowlist(claimID, root);

        assertTrue(merkle.isAllowedToClaim(proof, claimID, data[2]));
    }

    function testBasicAllowlistFuzz(uint256 size) public {
        size = bound(size, 4, 5_000);
        bytes32[] memory data = merkle.generateData(size, 10_000);
        bytes32 root = merkle.getRoot(data);
        bytes32[] memory proof = merkle.getProof(data, 2);

        uint256 claimID = 1;

        merkle.createAllowlist(claimID, root);

        assertTrue(merkle.isAllowedToClaim(proof, claimID, data[2]));
    }

    function testProcessClaimFuzz(uint256 size) public {
        size = bound(size, 4, 5_000);
        uint256 value = 10_000;
        bytes32[] memory data = merkle.generateData(size, value);
        bytes32 root = merkle.getRoot(data);
        bytes32[] memory proof = merkle.getProof(data, 2);

        uint256 claimID = 1;

        merkle.createAllowlist(claimID, root);

        bool allowed = merkle.isAllowedToClaim(proof, claimID, data[2]);
        assertTrue(allowed);

        bool processed = merkle.processClaim(proof, claimID, value);
        assertTrue(processed);

        bool claimed = merkle.hasBeenClaimed(claimID, data[2]);
        assertTrue(claimed);
    }
}
