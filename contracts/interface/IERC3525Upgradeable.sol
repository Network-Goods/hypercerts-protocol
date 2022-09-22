// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/IERC721EnumerableUpgradeable.sol";

/**
 * @title ERC-3525 Semi-Fungible Token Standard
 * @dev See https://eips.ethereum.org/EIPS/eip-3525
 */
interface IERC3525Upgradeable is IERC721EnumerableUpgradeable {
    /**
     *  @notice Emitted when the slot of a token changes
     *  @param tokenId Id of the token
     *  @param destination Receiving address
     *  @param value Value approved
     */
    event ApprovalValue(uint256 tokenId, address destination, uint256 value);

    /**
     *  @notice Emitted when the slot of a token changes
     *  @param tokenId Id of the token
     *  @param previousSlot Previous slot of the token
     *  @param slot New slot of the token
     */
    event SlotChanged(uint256 tokenId, uint256 previousSlot, uint256 slot);

    /**
     *  @notice Emitted when the slot of a token changes
     *  @param fromTokenId Id of the source token
     *  @param toTokenId Id of the destination token
     *  @param value Value transferred
     */
    event TransferValue(uint256 fromTokenId, uint256 toTokenId, uint256 value);

    function valueDecimals() external view returns (uint8);

    function slotOf(uint256 tokenId_) external view returns (uint256);

    function slotURI(uint256 slot_) external view returns (string memory);
}
