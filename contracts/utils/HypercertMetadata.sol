// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "./ArraysUpgradeable.sol";
import "./HypercertTypes.sol";
import "./StringsExtensions.sol";

/// @dev Hypercertificate metadata creation logic
library HypercertMetadata {
    using ArraysUpgradeable for uint64[2];
    using ArraysUpgradeable for uint256[];
    using ArraysUpgradeable for bytes32[];
    using StringsExtensions for bool;

    function slotURI(HypercertTypes.Claim memory claim, uint256[] memory fractions)
        public
        pure
        returns (string memory)
    {
        return
            string(
                bytes.concat(
                    abi.encode(
                        "data:application/json;{'name':'",
                        claim.name,
                        "','description':'",
                        claim.description,
                        "','properties':[",
                        _uriPropertyArray(
                            "work_timeframe",
                            "The period during which the work relating to the claim was done.",
                            claim.workTimeframe,
                            true
                        ),
                        ",",
                        _uriPropertyArray("work_scopes", "The scopes of work of the claim.", claim.workScopes, true),
                        ",",
                        _uriPropertyArray(
                            "impact_timeframe",
                            "The period during which the impact relating to the claim was made.",
                            claim.impactTimeframe,
                            true
                        ),
                        ","
                    ),
                    abi.encode(
                        _uriPropertyArray(
                            "impact_scopes",
                            "The scopes of impact of the claim.",
                            claim.impactScopes,
                            true
                        ),
                        ",",
                        _uriPropertyArray(
                            "total_units",
                            "Total units issued across all tokens with this slot.",
                            claim.totalUnits,
                            false
                        ),
                        ",",
                        _uriPropertyArray("units", "Units issued across all tokens with this slot.", fractions, false),
                        ",",
                        _uriPropertyArray(
                            "external_link",
                            "URI of additional data related to the claim.",
                            claim.URI,
                            false
                        ),
                        "]}"
                    )
                )
            );
    }

    function tokenURI(HypercertTypes.Claim memory claim, uint256 balance) public pure returns (string memory) {
        return
            string(
                bytes.concat(
                    abi.encode(
                        "'name':'",
                        claim.name,
                        "','description':'",
                        claim.description,
                        ",'balance':",
                        balance,
                        ",'slot':",
                        claim.claimHash,
                        "','properties':[",
                        _uriPropertyArray(
                            "work_timeframe",
                            "The period during which the work relating to the claim was done.",
                            claim.workTimeframe,
                            true
                        ),
                        ",",
                        _uriPropertyArray("work_scopes", "The scopes of work of the claim.", claim.workScopes, true),
                        ",",
                        _uriPropertyArray(
                            "impact_timeframe",
                            "The period during which the impact relating to the claim was made.",
                            claim.impactTimeframe,
                            true
                        )
                    ),
                    abi.encode(
                        ",",
                        _uriPropertyArray(
                            "impact_scopes",
                            "The scopes of impact of the claim.",
                            claim.impactScopes,
                            true
                        ),
                        ",",
                        _uriPropertyArray(
                            "total_units",
                            "Total units issued across all tokens with this slot.",
                            claim.totalUnits,
                            false
                        ),
                        ",",
                        _uriPropertyArray("units", "Units issued to this token.", balance, false),
                        ",",
                        _uriPropertyArray(
                            "fraction",
                            "Fraction issued to this token.",
                            balance / claim.totalUnits,
                            false
                        ),
                        ",",
                        _uriPropertyArray(
                            "external_link",
                            "URI of additional data related to the claim.",
                            claim.URI,
                            false
                        ),
                        "}"
                    )
                )
            );
    }

    function _uriPropertyArray(
        string memory name_,
        string memory description_,
        string memory value_,
        bool isIntrinsic_
    ) private pure returns (string[9] memory) {
        return [
            "{'name':'",
            name_,
            "','description':'",
            description_,
            "','value':'",
            value_,
            "','is_intrinsic':",
            isIntrinsic_.toString(),
            "}"
        ];
    }

    function _uriPropertyArray(
        string memory name_,
        string memory description_,
        uint64[2] memory array_,
        bool isIntrinsic_
    ) private pure returns (string[9] memory) {
        return [
            "{'name':'",
            name_,
            "','description':'",
            description_,
            "','value':'",
            array_.toString(),
            "','is_intrinsic':",
            isIntrinsic_.toString(),
            "}"
        ];
    }

    function _uriPropertyArray(
        string memory name_,
        string memory description_,
        uint256[] memory array_,
        bool isIntrinsic_
    ) private pure returns (string[9] memory) {
        return [
            "{'name':'",
            name_,
            "','description':'",
            description_,
            "','value':'",
            array_.toString(),
            "','is_intrinsic':",
            isIntrinsic_.toString(),
            "}"
        ];
    }

    function _uriPropertyArray(
        string memory name_,
        string memory description_,
        bytes32[] memory array_,
        bool isIntrinsic_
    ) private pure returns (string[9] memory) {
        return [
            "{'name':'",
            name_,
            "','description':'",
            description_,
            "','value':'",
            array_.toString(),
            "','is_intrinsic':",
            isIntrinsic_.toString(),
            "}"
        ];
    }

    function _uriPropertyArray(
        string memory name_,
        string memory description_,
        uint256 value_,
        bool isIntrinsic_
    ) private pure returns (string[9] memory) {
        return [
            "{'name':'",
            name_,
            "','description':'",
            description_,
            "','value':'",
            string(abi.encode(value_)),
            "','is_intrinsic':",
            isIntrinsic_.toString(),
            "}"
        ];
    }
}
