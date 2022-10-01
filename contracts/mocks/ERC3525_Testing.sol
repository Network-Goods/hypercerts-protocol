// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "../ERC3525Upgradeable.sol";

/**
 * @dev Mock implementation of ERC3525 to expose private mutative functions
 */
// solhint-disable-next-line contract-name-camelcase
contract ERC3525_Testing is ERC3525Upgradeable {
    // solhint-disable-next-line no-empty-blocks
    function initialize() public initializer {
        // empty block
    }

    function mintValue(
        address to_,
        uint256 tokenId_,
        uint256 slot_,
        uint256 value_
    ) public {
        _mintValue(to_, tokenId_, slot_, value_);
    }

    function burn(uint256 tokenId_) public override {
        _burn(tokenId_);
    }

    function transfer(
        uint256 fromTokenId_,
        uint256 toTokenId_,
        uint256 value_
    ) public {
        _transfer(fromTokenId_, toTokenId_, value_);
    }

    function spendAllowance(
        address operator_,
        uint256 tokenId_,
        uint256 value_
    ) public {
        spendAllowance(operator_, tokenId_, value_);
    }

    function approveValue(
        uint256 tokenId_,
        address to_,
        uint256 value_
    ) public {
        _approveValue(tokenId_, to_, value_);
    }

    function slotURI(
        uint256 /*slot_*/
    ) public view virtual override returns (string memory) {
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

    function tokenURI(uint256 tokenID_)
        public
        view
        virtual
        override(ERC721Upgradeable, IERC721MetadataUpgradeable)
        returns (string memory)
    {
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
}
