// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "./interfaces/IHypercertMetadata.sol";
import "./utils/ArraysUpgradeable.sol";
import "./utils/StringsExtensions.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/Base64Upgradeable.sol";

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

    function workScopes(bytes32 workScopeId) external view returns (string memory);

    function impactScopes(bytes32 impactScopeId) external view returns (string memory);

    function rights(bytes32 rightsId) external view returns (string memory);

    function getImpactCert(uint256 claimID) external view returns (Claim memory);

    function balanceOf(uint256 tokenId) external view returns (uint256);
}

interface IHypercertSVG {
    function generateSvgHypercert(
        string memory name,
        string memory description,
        uint64[2] memory workTimeframe,
        uint64[2] memory impactTimeframe,
        uint256 totalUnits
    ) external view returns (string memory);

    function generateSvgFraction(
        string memory name,
        string memory description,
        uint64[2] memory workTimeframe,
        uint64[2] memory impactTimeframe,
        uint256 units,
        uint256 totalUnits
    ) external view returns (string memory);
}

/// @dev Hypercertificate metadata creation logic
contract HypercertMetadata is IHypercertMetadata {
    using ArraysUpgradeable for uint64[2];
    using ArraysUpgradeable for uint256[];
    using ArraysUpgradeable for string[];
    using StringsExtensions for bool;
    using StringsUpgradeable for uint256;

    address svgGenerator;

    constructor(address svgGenerationAddress) {
        svgGenerator = svgGenerationAddress;
    }

    function generateTokenURI(uint256 slotId, uint256 tokenId) external view virtual returns (string memory) {
        IHypercertMinter.Claim memory claim = IHypercertMinter(msg.sender).getImpactCert(slotId);
        uint256 units = IHypercertMinter(msg.sender).balanceOf(tokenId);

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64Upgradeable.encode(
                        abi.encodePacked(
                            '{"name":"',
                            claim.name,
                            '","description":"',
                            claim.description,
                            '","image":"',
                            _generateImageStringFraction(claim, units),
                            '","properties":{',
                            _slotProperties(claim),
                            ",",
                            _tokenProperties(claim, units),
                            "}}"
                        )
                    )
                )
            );
    }

    function generateSlotURI(uint256 slotId) external view virtual returns (string memory) {
        IHypercertMinter.Claim memory claim = IHypercertMinter(msg.sender).getImpactCert(slotId);
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64Upgradeable.encode(
                        abi.encodePacked(
                            '{"name":"',
                            claim.name,
                            '","description":"',
                            claim.description,
                            '","image":"',
                            _generateImageStringHypercert(claim),
                            '","properties":{',
                            _slotProperties(claim),
                            "}}"
                        )
                    )
                )
            );
    }

    function _slotProperties(IHypercertMinter.Claim memory claim) internal view virtual returns (string memory) {
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
                    _mapWorkscopeIdsToValues(claim.workScopes),
                    ",",
                    _propertyString(
                        "impact_timeframe",
                        "The period during which the impact relating to the claim was made.",
                        claim.impactTimeframe,
                        true
                    ),
                    ",",
                    _mapImpactScopesIdsToValues(claim.impactScopes),
                    ",",
                    _mapRightsIdsToValues(claim.rights),
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

    function _tokenProperties(IHypercertMinter.Claim memory claim, uint256 units)
        internal
        view
        virtual
        returns (string memory)
    {
        return
            string(
                abi.encodePacked(
                    _propertyString("units", "Units issued to this token.", units, false),
                    ",",
                    _propertyString("fraction", "Fraction issued to this token.", units / claim.totalUnits, false)
                )
            );
    }

    function _generateImageStringFraction(IHypercertMinter.Claim memory claim, uint256 units)
        internal
        view
        returns (string memory)
    {
        return
            string.concat(
                "data:image/svg+xml;base64,",
                Base64Upgradeable.encode(
                    bytes(
                        IHypercertSVG(svgGenerator).generateSvgFraction(
                            claim.name,
                            claim.description,
                            claim.workTimeframe,
                            claim.impactTimeframe,
                            units,
                            claim.totalUnits
                        )
                    )
                )
            );
    }

    function _generateImageStringHypercert(IHypercertMinter.Claim memory claim) internal view returns (string memory) {
        return
            string.concat(
                "data:image/svg+xml;base64,",
                Base64Upgradeable.encode(
                    bytes(
                        IHypercertSVG(svgGenerator).generateSvgHypercert(
                            claim.name,
                            claim.description,
                            claim.workTimeframe,
                            claim.impactTimeframe,
                            claim.totalUnits
                        )
                    )
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

    /// @dev use keys to look up values in the supplied mapping
    function _mapWorkscopeIdsToValues(bytes32[] memory keys) internal view returns (string memory) {
        uint256 len = keys.length;
        string[] memory values = new string[](len);
        for (uint256 i = 0; i < len; i++) {
            values[i] = IHypercertMinter(msg.sender).workScopes(keys[i]);
        }
        return
            string(
                abi.encodePacked(
                    '{"name":"work_scopes","description":"The scopes of work of the claim.","value":[',
                    values.toCsv(),
                    '],"is_intrinsic":"true"}'
                )
            );
    }

    /// @dev use keys to look up values in the supplied mapping
    function _mapImpactScopesIdsToValues(bytes32[] memory keys) internal view returns (string memory) {
        uint256 len = keys.length;
        string[] memory vals;
        if (len > 0) {
            string[] memory values = new string[](len);
            for (uint256 i = 0; i < len; i++) {
                values[i] = IHypercertMinter(msg.sender).impactScopes(keys[i]);
            }
            vals = values;
        }

        return
            string(
                abi.encodePacked(
                    '{"name":"impact_scopes","description":"The scopes of impact of the claim.","value":[',
                    vals.toCsv(),
                    '],"is_intrinsic":"true"}'
                )
            );
    }

    /// @dev use keys to look up values in the supplied mapping
    function _mapRightsIdsToValues(bytes32[] memory keys) internal view returns (string memory) {
        uint256 len = keys.length;
        string[] memory values = new string[](len);
        for (uint256 i = 0; i < len; i++) {
            values[i] = IHypercertMinter(msg.sender).rights(keys[i]);
        }
        return
            string(
                abi.encodePacked(
                    '{"name":"rights","description":"Rights associated with owning the hypercert (fractions)","value":[',
                    values.toCsv(),
                    '],"is_intrinsic":"true"}'
                )
            );
    }
}
