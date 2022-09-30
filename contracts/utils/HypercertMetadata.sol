// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

// import "./ArraysUpgradeable.sol";
// import "./StringsExtensions.sol";

/// @dev Hypercertificate metadata creation logic
interface HypercertMetadata {

}

// /// @dev Hypercertificate metadata creation logic
// library HypercertMetadata {
//     using ArraysUpgradeable for uint64[2];
//     using ArraysUpgradeable for uint256[];
//     using ArraysUpgradeable for bytes32[];
//     using StringsExtensions for bool;

//     struct ClaimData {
//         uint256 id;
//         uint64[2] workTimeframe;
//         uint64[2] impactTimeframe;
//         bytes32[] workScopes;
//         bytes32[] impactScopes;
//         uint256[] fractions;
//         uint256 totalUnits;
//         string name;
//         string description;
//         string URI;
//     }

//     function slotURI(ClaimData memory claim) public pure returns (string memory) {
//         return "data:application/json;";
//         // string(
//         //     bytes.concat(
//         //         abi.encodePacked(
//         //             'data:application/json;{"name":"',
//         //             claim.name,
//         //             '","description":"',
//         //             claim.description,
//         //             '","properties":[',
//         //             _propertyString(
//         //                 "work_timeframe",
//         //                 "The period during which the work relating to the claim was done.",
//         //                 claim.workTimeframe,
//         //                 true
//         //             ),
//         //             ",",
//         //             _propertyString("work_scopes", "The scopes of work of the claim.", claim.workScopes, true),
//         //             ",",
//         //             _propertyString(
//         //                 "impact_timeframe",
//         //                 "The period during which the impact relating to the claim was made.",
//         //                 claim.impactTimeframe,
//         //                 true
//         //             ),
//         //             ","
//         //         ),
//         //         abi.encodePacked(
//         //             _propertyString(
//         //                 "impact_scopes",
//         //                 "The scopes of impact of the claim.",
//         //                 claim.impactScopes,
//         //                 true
//         //             ),
//         //             ",",
//         //             _propertyString(
//         //                 "total_units",
//         //                 "Total units issued across all tokens with this slot.",
//         //                 claim.totalUnits,
//         //                 false
//         //             ),
//         //             ",",
//         //             _propertyString(
//         //                 "units",
//         //                 "Units issued across all tokens with this slot.",
//         //                 claim.fractions,
//         //                 false
//         //             ),
//         //             ",",
//         //             _propertyString(
//         //                 "external_link",
//         //                 "URI of additional data related to the claim.",
//         //                 claim.URI,
//         //                 false
//         //             ),
//         //             "]}"
//         //         )
//         //     )
//         // );
//     }

//     function tokenURI(ClaimData memory claim, uint256 balance) public pure returns (string memory) {
//         return "data:application/json;";
//         // return
//         //     string(
//         //         bytes.concat(
//         //             abi.encodePacked(
//         //                 'data:application/json;{"name":"',
//         //                 claim.name,
//         //                 '","description":"',
//         //                 claim.description,
//         //                 ',"balance":',
//         //                 balance,
//         //                 ',"slot":',
//         //                 claim.id,
//         //                 '","properties":[',
//         //                 _propertyString(
//         //                     "work_timeframe",
//         //                     "The period during which the work relating to the claim was done.",
//         //                     claim.workTimeframe,
//         //                     true
//         //                 ),
//         //                 ",",
//         //                 _propertyString("work_scopes", "The scopes of work of the claim.", claim.workScopes, true),
//         //                 ",",
//         //                 _propertyString(
//         //                     "impact_timeframe",
//         //                     "The period during which the impact relating to the claim was made.",
//         //                     claim.impactTimeframe,
//         //                     true
//         //                 )
//         //             ),
//         //             abi.encodePacked(
//         //                 ",",
//         //                 _propertyString(
//         //                     "impact_scopes",
//         //                     "The scopes of impact of the claim.",
//         //                     claim.impactScopes,
//         //                     true
//         //                 ),
//         //                 ",",
//         //                 _propertyString(
//         //                     "total_units",
//         //                     "Total units issued across all tokens with this slot.",
//         //                     claim.totalUnits,
//         //                     false
//         //                 ),
//         //                 ",",
//         //                 _propertyString("units", "Units issued to this token.", balance, false),
//         //                 ",",
//         //                 _propertyString(
//         //                     "fraction",
//         //                     "Fraction issued to this token.",
//         //                     balance / claim.totalUnits,
//         //                     false
//         //                 ),
//         //                 ",",
//         //                 _propertyString(
//         //                     "external_link",
//         //                     "URI of additional data related to the claim.",
//         //                     claim.URI,
//         //                     false
//         //                 ),
//         //                 "]}"
//         //             )
//         //         )
//         //     );
//     }

//     function _propertyString(
//         string memory name_,
//         string memory description_,
//         string memory value_,
//         bool isIntrinsic_
//     ) private pure returns (string memory) {
//         return
//             string(
//                 abi.encodePacked(
//                     '{"name":"',
//                     name_,
//                     '","description":"',
//                     description_,
//                     '","value":"',
//                     value_,
//                     '","is_intrinsic":"',
//                     isIntrinsic_.toString(),
//                     '"}'
//                 )
//             );
//     }

//     function _propertyString(
//         string memory name_,
//         string memory description_,
//         uint64[2] memory array_,
//         bool isIntrinsic_
//     ) private pure returns (string memory) {
//         return
//             string(
//                 abi.encodePacked(
//                     '{"name":"',
//                     name_,
//                     '","description":"',
//                     description_,
//                     '","value":"',
//                     array_.toString(),
//                     '","is_intrinsic":"',
//                     isIntrinsic_.toString(),
//                     '"}'
//                 )
//             );
//     }

//     function _propertyString(
//         string memory name_,
//         string memory description_,
//         uint256[] memory array_,
//         bool isIntrinsic_
//     ) private pure returns (string memory) {
//         return
//             string(
//                 abi.encodePacked(
//                     '{"name":"',
//                     name_,
//                     '","description":"',
//                     description_,
//                     '","value":"',
//                     array_.toString(),
//                     '","is_intrinsic":"',
//                     isIntrinsic_.toString(),
//                     '"}'
//                 )
//             );
//     }

//     function _propertyString(
//         string memory name_,
//         string memory description_,
//         bytes32[] memory array_,
//         bool isIntrinsic_
//     ) private pure returns (string memory) {
//         return
//             string(
//                 abi.encodePacked(
//                     '{"name":"',
//                     name_,
//                     '","description":"',
//                     description_,
//                     '","value":"',
//                     array_.toString(),
//                     '","is_intrinsic":"',
//                     isIntrinsic_.toString(),
//                     '"}'
//                 )
//             );
//     }

//     function _propertyString(
//         string memory name_,
//         string memory description_,
//         uint256 value_,
//         bool isIntrinsic_
//     ) private pure returns (string memory) {
//         return
//             string(
//                 abi.encodePacked(
//                     '{"name":"',
//                     name_,
//                     '","description":"',
//                     description_,
//                     '","value":"',
//                     string(abi.encode(value_)),
//                     '","is_intrinsic":"',
//                     isIntrinsic_.toString(),
//                     '"}'
//                 )
//             );
//     }
// }
