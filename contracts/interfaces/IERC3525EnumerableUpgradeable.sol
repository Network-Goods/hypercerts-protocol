// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "./IERC3525Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC721EnumerableUpgradeable.sol";

/**
 * @title ERC-3525 Semi-Fungible Token Standard, optional enumerable extension
 * @dev Interfaces for any contract that wants to support query of the Uniform Resource Identifier
 *  (URI) for the ERC3525 contract as well as a specified slot.
 *  Because of the higher reliability of data stored in smart contracts compared to data stored in
 *  centralized systems, it is recommended that metadata, including `contractURI`, `slotURI` and
 *  `tokenURI`, be directly returned in JSON format, instead of being returned with a url pointing
 *  to any resource stored in a centralized system.
 *  See https://eips.ethereum.org/EIPS/eip-3525
 * Note: the ERC-165 identifier for this interface is 0xe1600902.
 */
interface IERC3525EnumerableUpgradeable is IERC3525Upgradeable, IERC721EnumerableUpgradeable {

}
