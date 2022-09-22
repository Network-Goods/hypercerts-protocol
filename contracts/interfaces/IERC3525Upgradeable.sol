// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

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

    function approve(
        uint256 tokenId_,
        address to_,
        uint256 value_
    ) external payable;

    function allowance(uint256 tokenId_, address operator_) external view returns (uint256);

    function balanceOf(uint256 tokenId_) external view returns (uint256);

    function valueDecimals() external view returns (uint8);

    function slotOf(uint256 tokenId_) external view returns (uint256);

    function slotURI(uint256 slot_) external view returns (string memory);

    function transferFrom(
        uint256 fromTokenId_,
        address to_,
        uint256 value_
    ) external payable returns (uint256);

    function transferFrom(
        uint256 fromTokenId_,
        uint256 toTokenId_,
        uint256 value_
    ) external payable;
}
