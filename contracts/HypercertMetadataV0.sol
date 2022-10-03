// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "./interfaces/IHypercertMetadata.sol";
import "./utils/ArraysUpgradeable.sol";
import "./utils/StringsExtensions.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";

interface IHypercertMinter {
    struct Claim {
        bytes32 claimHash;
        uint64[2] workTimeframe;
        uint64[2] impactTimeframe;
        bytes32[] workScopes;
        bytes32[] impactScopes;
        bytes32[] rights;
        address[] contributors;
        uint256 totalUnits;
        uint16 version;
        bool exists;
        string name;
        string description;
        string uri;
    }

    function getImpactCert(uint256 claimID) external view returns (Claim memory);

    function balanceOf(uint256 tokenId) external view returns (uint256);
}

/// @dev Hypercertificate metadata creation logic
contract HypercertMetadataV0 is IHypercertMetadata {
    using ArraysUpgradeable for uint64[2];
    using ArraysUpgradeable for uint256[];
    using ArraysUpgradeable for string[];
    using StringsExtensions for bool;
    using StringsUpgradeable for uint256;

    function generateSlotURI(uint256 slotId, uint256 tokenId) external view virtual returns (string memory) {
        IHypercertMinter.Claim memory claim = IHypercertMinter(msg.sender).getImpactCert(slotId);
        return
            string(
                abi.encodePacked(
                    'data:application/json;{"name":"',
                    claim.name,
                    '","description":"',
                    claim.description,
                    '","properties":[',
                    _slotProperties(claim),
                    _tokenProperties(claim, tokenId),
                    "]}"
                )
            );
    }

    function generateSlotURI(uint256 slotId) external view virtual returns (string memory) {
        IHypercertMinter.Claim memory claim = IHypercertMinter(msg.sender).getImpactCert(slotId);
        return
            string(
                abi.encodePacked(
                    'data:application/json;{"name":"',
                    claim.name,
                    '","description":"',
                    claim.description,
                    '","properties":[',
                    _slotProperties(claim),
                    "]}"
                )
            );
    }

    // function generateTokenURI(uint256 slotId, uint256 tokenId) external pure virtual returns (string memory) {
    //     IHypercertMinter.Claim memory claim = IHypercertMinter(msg.sender).getImpactCert(slotId);
    //     return
    //         string(
    //             abi.encodePacked(
    //                 'data:application/json;{"name":"',
    //                 claim.name,
    //                 '","description":"',
    //                 claim.description,
    //                 '","properties":[',
    //                 _slotProperties(claim),
    //                 _tokenProperties(claim, tokenId),
    //                 "]}"
    //             )
    //         );
    // }

    // function tokenURI(uint256 tokenId) external pure virtual returns (string memory) {
    //     return
    //         string(
    //             abi.encodePacked(
    //                 'data:application/json;{"name":"',
    //                 claim.name,
    //                 '","description":"',
    //                 claim.description,
    //                 ',"balance":',
    //                 balance.toString(),
    //                 ',"slot":',
    //                 claim.id.toString(),
    //                 ',"properties":[',
    //                 _tokenProperties(claim, balance),
    //                 "]}"
    //             )
    //         );
    // }

    function _slotProperties(IHypercertMinter.Claim memory claim) internal pure virtual returns (string memory) {
        return
            string(
                abi.encodePacked(
                    _propertyString(
                        "work_timeframe",
                        "The period during which the work relating to the claim was done.",
                        claim.workTimeframe,
                        true
                    ),
                    ",",
                    _propertyString("work_scopes", "The scopes of work of the claim.", claim.workScopes, true),
                    ",",
                    _propertyString(
                        "impact_timeframe",
                        "The period during which the impact relating to the claim was made.",
                        claim.impactTimeframe,
                        true
                    ),
                    ",",
                    _propertyString("impact_scopes", "The scopes of impact of the claim.", claim.impactScopes, true),
                    ",",
                    _propertyString(
                        "total_units",
                        "Total units issued across all tokens with this slot.",
                        claim.totalUnits,
                        false
                    ),
                    ",",
                    _propertyString("external_link", "URI of additional data related to the claim.", claim.uri, false)
                )
            );
    }

    function _tokenProperties(IHypercertMinter.Claim memory claim, uint256 tokenId)
        internal
        view
        virtual
        returns (string memory)
    {
        uint256 units = IHypercertMinter(msg.sender).balanceOf(tokenId);
        return
            string(
                abi.encodePacked(
                    _propertyString("units", "Units issued to this token.", units, false),
                    ",",
                    _propertyString("fraction", "Fraction issued to this token.", units / claim.totalUnits, false)
                )
            );
    }

    function _propertyString(
        string memory name_,
        string memory description_,
        string memory value_,
        bool isIntrinsic_
    ) internal pure virtual returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '{"name":"',
                    name_,
                    '","description":"',
                    description_,
                    '","value":"',
                    value_,
                    '","is_intrinsic":"',
                    isIntrinsic_.toString(),
                    '"}'
                )
            );
    }

    function _propertyString(
        string memory name_,
        string memory description_,
        uint256 value_,
        bool isIntrinsic_
    ) internal pure virtual returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '{"name":"',
                    name_,
                    '","description":"',
                    description_,
                    '","value":',
                    value_.toString(),
                    ',"is_intrinsic":"',
                    isIntrinsic_.toString(),
                    '"}'
                )
            );
    }

    function _propertyString(
        string memory name_,
        string memory description_,
        bytes32[] memory value_,
        bool isIntrinsic_
    ) internal pure virtual returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '{"name":"',
                    name_,
                    '","description":"',
                    description_,
                    '","value":',
                    value_,
                    ',"is_intrinsic":"',
                    isIntrinsic_.toString(),
                    '"}'
                )
            );
    }

    function _propertyString(
        string memory name_,
        string memory description_,
        uint256[] memory array_,
        bool isIntrinsic_
    ) internal pure virtual returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '{"name":"',
                    name_,
                    '","description":"',
                    description_,
                    '","value":"',
                    array_.toCsv(),
                    '","is_intrinsic":"',
                    isIntrinsic_.toString(),
                    '"}'
                )
            );
    }

    function _propertyString(
        string memory name_,
        string memory description_,
        uint64[2] memory array_,
        bool isIntrinsic_
    ) internal pure virtual returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '{"name":"',
                    name_,
                    '","description":"',
                    description_,
                    '","value":"',
                    array_.toString(),
                    '","is_intrinsic":"',
                    isIntrinsic_.toString(),
                    '"}'
                )
            );
    }

    function _propertyString(
        string memory name_,
        string memory description_,
        string[] memory array_,
        bool isIntrinsic_
    ) internal pure virtual returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '{"name":"',
                    name_,
                    '","description":"',
                    description_,
                    '","value":"',
                    array_.toCsv(),
                    '","is_intrinsic":"',
                    isIntrinsic_.toString(),
                    '"}'
                )
            );
    }
}
