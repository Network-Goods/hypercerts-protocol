// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/// @title Interface for hypercert token interactions
/// @author bitbeckers
/// @notice This interface declares the required functionality for a hypercert token
/// @notice This interface does not specify the underlying token type (e.g. 721 or 1155)
interface IHypercertToken {
    /// @dev Emitted when token with tokenID `claimID` is stored, with external data reference via `uri`.
    event ClaimStored(uint256 indexed claimID, string uri);

    /// @dev Function called to store a claim referenced via `uri` with a maximum number of fractions `units`.
    function mintClaim(uint256 units, string memory uri) external;

    /// @dev Function called to store a claim referenced via `uri` with a set of `fractions`.
    /// @dev Fractions are internally summed to total units.
    function mintClaimWithFractions(uint256[] memory fractions, string memory uri) external;

    /// @dev Function called to split `tokenID` owned by `account` into units declared in `values`.
    /// @notice The sum of `values` must equal the current value of `_tokenID`.
    // TODO _account might not be needed? Or operator?
    function splitValue(address account, uint256 tokenID, uint256[] memory _values) external;

    /// @dev Function called to merge tokens within `tokenIDs`.
    /// @notice Tokens that have been merged are burned.
    function mergeValue(uint256[] memory tokenIDs) external;

    /// @dev Function to burn the token at `tokenID` for `account`
    /// @notice Operator must be allowed by `creator` and the token must represent the total amount of available units.
    // TODO _account might not be needed? Or operator?
    function burnValue(address account, uint256 tokenID) external;

    /// @dev Returns the `units` held by a (fractional) token at `claimID`
    /// @dev If `tokenID` is a base type, the total amount of `units` for the claim is returned.
    /// @dev If `tokenID` is a fractional token, the `units` held by the token is returned
    function unitsOf(uint256 tokenID) external view returns (uint256 units);

    /// @dev Returns the `units` held by `account` of a (fractional) token at `claimID`
    /// @dev If `tokenID` is a base type, the total amount of `units` held by `account` for the claim is returned.
    /// @dev If `tokenID` is a fractional token, the `units` held by `account` the token is returned
    function unitsOf(address account, uint256 tokenID) external view returns (uint256 units);
}