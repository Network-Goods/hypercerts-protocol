// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import { IHypercertToken } from "./interfaces/IHypercertToken.sol";
import { SemiFungible1155 } from "./SemiFungible1155.sol";
import { AllowlistMinter } from "./AllowlistMinter.sol";

/// @title Contract for managing hypercert claims and whitelists
/// @author bitbeckers
/// @notice Implementation of the HypercertTokenInterface using { SemiFungible1155 } as underlying token.
/// @notice This contract supports whitelisted minting via { AllowlistMinter }.
/// @dev Wrapper contract to expose and chain functions.
contract HypercertMinter is IHypercertToken, SemiFungible1155, AllowlistMinter {
    // solhint-disable-next-line const-name-snakecase
    string public constant name = "HypercertMinter";

    /// INIT

    /// @dev see { openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol }
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @dev see { openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol }
    function initialize() public virtual initializer {
        __SemiFungible1155_init();
    }

    /// EXTERNAL

    /// @notice Mint a semi-fungible token for the impact claim referenced via `uri`
    /// @dev see {IHypercertToken}
    function mintClaim(uint256 units, string memory uri) external {
        uint256 claimID = _mintValue(msg.sender, units, uri);
        emit ClaimStored(claimID, uri, units);
    }

    /// @notice Mint semi-fungible tokens for the impact claim referenced via `uri`
    /// @dev see {IHypercertToken}
    function mintClaimWithFractions(uint256 units, uint256[] memory fractions, string memory uri) external {
        uint256 claimID = _mintValue(msg.sender, fractions, uri);
        emit ClaimStored(claimID, uri, units);
    }

    /// @notice Mint a semi-fungible token representing a fraction of the claim
    /// @dev Calls AllowlistMinter to verify `proof`.
    /// @dev Mints the `amount` of units for the hypercert stored under `claimID`
    function mintClaimFromAllowlist(bytes32[] calldata proof, uint256 claimID, uint256 units) external {
        _processClaim(proof, claimID, units);
        _mintClaim(claimID, units);
    }

    /// @notice Register a claim and the whitelist for minting token(s) belonging to that claim
    /// @dev Calls SemiFungible1155 to store the claim referenced in `uri` with amount of `units`
    /// @dev Calls AlloslistMinter to store the `merkleRoot` as proof to authorize claims
    function createAllowlist(uint256 units, bytes32 merkleRoot, string memory uri) external {
        uint256 claimID = _createTokenType(units, uri);
        _createAllowlist(claimID, merkleRoot);
        emit ClaimStored(claimID, uri, units);
    }

    /// @notice Split a claimtokens value into parts with summed value equal to the original
    /// @dev see {IHypercertToken}
    function splitValue(address _account, uint256 _tokenID, uint256[] memory _values) external {
        _splitValue(_account, _tokenID, _values);
    }

    /// @notice Merge the value of tokens belonging to the same claim
    /// @dev see {IHypercertToken}
    function mergeValue(uint256[] memory _fractionIDs) external {
        _mergeValue(_fractionIDs);
    }

    /// @notice Burn a claimtoken
    /// @dev see {IHypercertToken}
    function burnValue(address _account, uint256 _tokenID) external {
        _burnValue(_account, _tokenID);
    }

    /// @dev see {IHypercertToken}
    function unitsOf(uint256 tokenID) external view returns (uint256 units) {
        units = _unitsOf(tokenID);
    }

    /// @dev see {IHypercertToken}
    function unitsOf(address account, uint256 tokenID) external view returns (uint256 units) {
        units = _unitsOf(account, tokenID);
    }

    /// INTERNAL

    /// @dev see { openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol }
    function _authorizeUpgrade(address newImplementation) internal virtual override onlyOwner {
        // solhint-disable-previous-line no-empty-blocks
    }
}
