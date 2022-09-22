// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/IERC721EnumerableUpgradeable.sol";

/**
 * @title ERC-3525 Semi-Fungible Token Standard
 * @dev See https://eips.ethereum.org/EIPS/eip-3525
 */
interface IERC3525Upgradeable is IERC721EnumerableUpgradeable {
    function valueDecimals() external view returns (uint8);

    function slotOf(uint256 tokenId_) external view returns (uint256);

    function slotURI(uint256 slot_) external view returns (string memory);
}
