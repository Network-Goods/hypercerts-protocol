// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import { IHypercertMinter } from "./interfaces/IHypercertMinter.sol";
import { SemiFungible1155 } from "./SemiFungible1155.sol";
import { AllowlistMinter } from "./AllowlistMinter.sol";

contract HypercertMinter is IHypercertMinter, SemiFungible1155, AllowlistMinter {
    // solhint-disable-next-line const-name-snakecase
    string public constant name = "HypercertMinter";

    event ClaimStored(uint256 indexed claimID, string uri);

    /// INIT

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() public virtual initializer {
        __SemiFungible1155_init();
    }

    /// EXTERNAL

    function mintClaim(uint256 units, string memory uri) external {
        uint256 claimID = _mintValue(msg.sender, units, uri);
        emit ClaimStored(claimID, uri);
    }

    function mintClaimWithFractions(uint256[] memory fractions, string memory uri) external {
        uint256 claimID = _mintValue(msg.sender, fractions, uri);
        emit ClaimStored(claimID, uri);
    }

    function mintClaimFromAllowlist(bytes32[] calldata proof, uint256 claimID, uint256 amount) external {
        _processClaim(proof, claimID, amount);
        _mintClaim(claimID, amount);
    }

    function createAllowlist(uint256 units, bytes32 merkleRoot, string memory uri) external {
        uint256 claimID = _createTokenType(units, uri);
        _createAllowlist(claimID, merkleRoot);
        emit ClaimStored(claimID, uri);
    }

    /// INTERNAL

    function _authorizeUpgrade(address newImplementation) internal virtual override onlyOwner {
        // solhint-disable-previous-line no-empty-blocks
    }
}
