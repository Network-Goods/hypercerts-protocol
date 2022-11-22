// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "../ERC3525SlotEnumerableUpgradeable.sol";

/**
 * @dev Mock implementation of ERC3525 to expose private mutative functions
 */
// solhint-disable-next-line contract-name-camelcase
contract ERC3525_Testing is ERC3525SlotEnumerableUpgradeable {
    // solhint-disable-next-line no-empty-blocks
    function initialize() public initializer {
        // empty block
    }

    function mintValue(
        address to_,
        uint256 slot_,
        uint256 value_
    ) public {
        _mintValue(to_, slot_, value_);
    }

    function burn(uint256 tokenId_) public {
        _burn(tokenId_);
    }

    function transferValue(
        uint256 fromTokenId_,
        uint256 toTokenId_,
        uint256 value_
    ) public {
        _transferValue(fromTokenId_, toTokenId_, value_);
    }

    function spendAllowance(
        address operator_,
        uint256 tokenId_,
        uint256 value_
    ) public {
        _spendAllowance(operator_, tokenId_, value_);
    }

    function approveValue(
        uint256 tokenId_,
        address to_,
        uint256 value_
    ) public {
        _approveValue(tokenId_, to_, value_);
    }

    function isApprovedOrOwner(address operator_, uint256 tokenId_) public view virtual returns (bool) {
        return _isApprovedOrOwner(operator_, tokenId_);
    }

    function splitValue(uint256 fromToken_, uint256 value_) public virtual returns (uint256 tokenId) {
        return _splitValue(fromToken_, value_);
    }

    function mergeValue(uint256 fromToken_, uint256 toToken_) public virtual returns (uint256 tokenId) {
        return _mergeValue(fromToken_, toToken_);
    }

    function slotURI(
        uint256 /*slot_*/
    ) public pure override returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "data:application/json;{"
                    "name"
                    ":"
                    "Slot Type A"
                    ","
                    "description"
                    ":"
                    "Slot Type A description"
                    "}"
                )
            );
    }

    function tokenURI(uint256 tokenID_) public view override returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "data:application/json;{"
                    "name"
                    ":"
                    "Asset Type A"
                    ","
                    "description"
                    ":"
                    "Asset Type A description"
                    ","
                    "balance",
                    balanceOf(tokenID_),
                    ","
                    "slot"
                    ":",
                    slotOf(tokenID_),
                    "}"
                )
            );
    }

    function valueDecimals() public pure override returns (uint8) {
        return 0;
    }
}
