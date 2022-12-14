// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "./interfaces/IHyperCertMetadata.sol";
import "./utils/ArraysUpgradeable.sol";
import "./utils/StringsExtensions.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/Base64Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

interface IHyperCertMinter {
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

interface IHyperCertSVG {
    function generateSvgHyperCert(
        string memory name,
        string[] memory scopesOfImpact,
        uint64[2] memory workTimeframe,
        uint64[2] memory impactTimeframe,
        uint256 totalUnits
    ) external view returns (string memory);

    function generateSvgFraction(
        string memory name,
        string[] memory scopesOfImpact,
        uint64[2] memory workTimeframe,
        uint64[2] memory impactTimeframe,
        uint256 units,
        uint256 totalUnits
    ) external view returns (string memory);
}

/// @dev Hypercertificate metadata creation logic
// TODO optimise where to call string data
contract HyperCertMetadata is IHyperCertMetadata, Initializable, AccessControlUpgradeable, UUPSUpgradeable {
    using ArraysUpgradeable for uint64[2];
    using ArraysUpgradeable for uint256[];
    using ArraysUpgradeable for string[];
    using StringsExtensions for bool;
    using StringsUpgradeable for uint256;

    /// @notice User role required in order to upgrade the contract
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    /// @notice Current version of the contract
    uint16 internal _version;

    IHyperCertSVG internal _svgGenerator;

    /*******************
     * DEPLOY
     ******************/

    /// @notice Contract constructor logic
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @notice Contract initialization logic
    function initialize(address svgGenerationAddress) public initializer {
        _svgGenerator = IHyperCertSVG(svgGenerationAddress);

        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
    }

    function generateContractURI() external view returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64Upgradeable.encode(
                        abi.encodePacked(
                            '{"name":"HyperCerts"'
                            '","description":"HyperCerts create an interoperable data layer to account for'
                            " actions that are expected to have positive impact. They are a tool to build"
                            ' scalable reward systems for impact.","image":"'
                            "https://bafkreifjgpewz56lvddyau7xsbaefm3quc3k4mk34cokqkl2hxuyihun7q.ipfs.nftstorage.link/"
                            '","external_url":"https://www.hypercerts.xyz"}'
                        )
                    )
                )
            );
    }

    function generateTokenURI(uint256 slotId, uint256 tokenId) external view virtual returns (string memory) {
        IHyperCertMinter.Claim memory claim = IHyperCertMinter(msg.sender).getImpactCert(slotId);
        uint256 units = IHyperCertMinter(msg.sender).balanceOf(tokenId);
        string[] memory impactScopes = _mapImpactScopesIdsToValues(claim.impactScopes);

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
                            _generateImageStringFraction(claim, units, impactScopes),
                            '","external_url":"',
                            claim.uri,
                            '","properties":{',
                            abi.encodePacked(
                                '"fraction":',
                                _propertyStringRange(
                                    "Fraction",
                                    "Units held by fraction.",
                                    units,
                                    claim.totalUnits,
                                    false
                                ),
                                ","
                            ),
                            _hyperCertDimensions(claim),
                            "}}"
                        )
                    )
                )
            );
    }

    function generateSlotURI(uint256 slotId) external view virtual returns (string memory) {
        IHyperCertMinter.Claim memory claim = IHyperCertMinter(msg.sender).getImpactCert(slotId);

        string[] memory impactScopes = _mapImpactScopesIdsToValues(claim.impactScopes);

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
                            _generateImageStringHypercert(claim, impactScopes),
                            '","external_url":"',
                            claim.uri,
                            '","properties":{',
                            abi.encodePacked(
                                '"totalUnits":',
                                _propertyString("Total units", "Units held by fraction.", claim.totalUnits, false),
                                ","
                            ),
                            _hyperCertDimensions(claim),
                            "}}"
                        )
                    )
                )
            );
    }

    function _hyperCertDimensions(IHyperCertMinter.Claim memory claim) internal view returns (string memory) {
        return
            string(
                abi.encodePacked(
                    abi.encodePacked(
                        '"hyperCertID":',
                        _propertyString(
                            "HyperCert ID",
                            "Unique identifier of HyperCert in contract.",
                            uint256(claim.claimHash).toString(),
                            false
                        ),
                        ","
                    ),
                    abi.encodePacked(
                        '"scopesOfWork":',
                        _propertyStringCSV(
                            "Scopes of Work",
                            "Scopes of work encapsulated in this hypercert fraction.",
                            _mapWorkScopesIdsToValues(claim.workScopes).toCsv(),
                            true
                        ),
                        ","
                    ),
                    abi.encodePacked(
                        '"scopesOfImpact":',
                        _propertyStringCSV(
                            "Scopes of Impact",
                            "Scopes of impact encapsulated in this hypercert fraction.",
                            _mapImpactScopesIdsToValues(claim.impactScopes).toCsv(),
                            true
                        ),
                        ","
                    ),
                    abi.encodePacked(
                        '"timeOfWork":',
                        _propertyString(
                            "Timeframe of work",
                            "Timeframe in which work to achieve impact has been performed",
                            claim.workTimeframe,
                            true
                        ),
                        ","
                    ),
                    abi.encodePacked(
                        '"timeOfImpact":',
                        _propertyString(
                            "Timeframe of impact",
                            "Timeframe in which impact is realized",
                            claim.impactTimeframe,
                            true
                        ),
                        ","
                    ),
                    abi.encodePacked(
                        '"rights":',
                        _propertyStringCSV(
                            "Rights",
                            "Rights associated with owning the hypercert (fractions)",
                            _mapRightsIdsToValues(claim.rights).toCsv(),
                            true
                        )
                    )
                )
            );
    }

    function _generateImageStringFraction(
        IHyperCertMinter.Claim memory claim,
        uint256 units,
        string[] memory impactScopes
    ) internal view returns (string memory) {
        return
            string.concat(
                "data:image/svg+xml;base64,",
                Base64Upgradeable.encode(
                    bytes(
                        _svgGenerator.generateSvgFraction(
                            claim.name,
                            impactScopes,
                            claim.workTimeframe,
                            claim.impactTimeframe,
                            units,
                            claim.totalUnits
                        )
                    )
                )
            );
    }

    function _generateImageStringHypercert(IHyperCertMinter.Claim memory claim, string[] memory scopesOfImpact)
        internal
        view
        returns (string memory)
    {
        return
            string.concat(
                "data:image/svg+xml;base64,",
                Base64Upgradeable.encode(
                    bytes(
                        _svgGenerator.generateSvgHyperCert(
                            claim.name,
                            scopesOfImpact,
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

    function _propertyStringCSV(
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
                    '","value":[',
                    value_,
                    '],"is_intrinsic":"',
                    isIntrinsic_.toString(),
                    '"}'
                )
            );
    }

    function _propertyStringRange(
        string memory name_,
        string memory description_,
        uint256 value_,
        uint256 maxValue,
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
                    ',"max_value":',
                    maxValue.toString(),
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
                    '","value":',
                    array_.toString(),
                    ',"is_intrinsic":"',
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
    function _mapWorkScopesIdsToValues(bytes32[] memory keys) internal view returns (string[] memory vals) {
        uint256 len = keys.length;
        if (len > 0) {
            string[] memory values = new string[](len);
            for (uint256 i = 0; i < len; i++) {
                values[i] = IHyperCertMinter(msg.sender).workScopes(keys[i]);
            }
            vals = values;
        }
    }

    /// @dev use keys to look up values in the supplied mapping
    function _mapImpactScopesIdsToValues(bytes32[] memory keys) internal view returns (string[] memory vals) {
        uint256 len = keys.length;
        if (len > 0) {
            string[] memory values = new string[](len);
            for (uint256 i = 0; i < len; i++) {
                values[i] = IHyperCertMinter(msg.sender).impactScopes(keys[i]);
            }
            vals = values;
        }
    }

    /// @dev use keys to look up values in the supplied mapping
    function _mapRightsIdsToValues(bytes32[] memory keys) internal view returns (string[] memory vals) {
        uint256 len = keys.length;
        if (len > 0) {
            string[] memory values = new string[](len);
            for (uint256 i = 0; i < len; i++) {
                values[i] = IHyperCertMinter(msg.sender).rights(keys[i]);
            }
            vals = values;
        }
    }

    /*******************
     * ADMIN
     ******************/

    /// @notice gets the current version of the contract
    function version() public view virtual returns (uint256) {
        return _version;
    }

    /// @notice Update the contract version number
    /// @notice Only allowed for member of UPGRADER_ROLE
    function updateVersion() external onlyRole(UPGRADER_ROLE) {
        _version += 1;
    }

    /// @notice Returns a flag indicating if the contract supports the specified interface
    /// @param interfaceId Id of the interface
    /// @return true, if the interface is supported
    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /// @notice upgrade authorization logic
    /// @dev adds onlyRole(UPGRADER_ROLE) requirement
    function _authorizeUpgrade(
        address /*newImplementation*/
    )
        internal
        view
        override
        onlyRole(UPGRADER_ROLE) // solhint-disable-next-line no-empty-blocks
    {
        //empty block
    }
}
