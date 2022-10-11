// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "./ERC3525SlotEnumerableUpgradeable.sol";
import "./interfaces/IHyperCertMetadata.sol";
import "./utils/ArraysUpgradeable.sol";
import "./utils/StringsExtensions.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

error EmptyInput();
error DuplicateScope();
error InvalidScope();
error InvalidTimeframe(uint64 from, uint64 to);
error ConflictingClaim();
error InvalidInput();

/// @title Hypercertificate minting logic
/// @notice Contains functions and events to initialize and issue a hypercertificate
/// @author bitbeckers, mr_bluesky
contract HyperCertMinter is Initializable, ERC3525SlotEnumerableUpgradeable, AccessControlUpgradeable, UUPSUpgradeable {
    using ArraysUpgradeable for uint64[];

    /// @notice Contract name
    string public constant NAME = "HyperCerts";
    /// @notice Token symbol
    string public constant SYMBOL = "HCRT";
    /// @notice Token value decimals
    uint8 public constant DECIMALS = 0;
    /// @notice User role required in order to upgrade the contract
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    /// @notice Current version of the contract
    uint16 internal _version;
    /// @notice Hypercert metadata contract
    IHyperCertMetadata internal _metadata;

    /// @notice Mapping of id's to work-scopes
    mapping(bytes32 => string) public workScopes;
    /// @notice Mapping of id's to impact-scopes
    mapping(bytes32 => string) public impactScopes;
    /// @notice Mapping of id's to rights
    mapping(bytes32 => string) public rights;
    mapping(address => mapping(bytes32 => bool)) internal _contributorImpacts;
    mapping(uint256 => Claim) internal _hyperCerts;

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
        address minter;
    }

    /*******************
     * EVENTS
     ******************/

    /// @notice Emitted when an impact is claimed.
    /// @param id Id of the claimed impact.
    /// @param minter Address of cert minter.
    /// @param fractions Units of tokens issued under the hypercert.
    event ImpactClaimed(uint256 id, address minter, uint64[] fractions);

    /// @notice Emitted when a new impact scope is added.
    /// @param id Id of the impact scope.
    /// @param text Short text code of the impact scope.
    event ImpactScopeAdded(bytes32 id, string text);

    /// @notice Emitted when a new right is added.
    /// @param id Id of the right.
    /// @param text Short text code of the right.
    event RightAdded(bytes32 id, string text);

    /// @notice Emitted when a new work scope is added.
    /// @param id Id of the work scope.
    /// @param text Short text code of the work scope.
    event WorkScopeAdded(bytes32 id, string text);

    /*******************
     * DEPLOY
     ******************/

    /// @notice Contract constructor logic
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @notice Contract initialization logic
    function initialize(address metadataAddress) public initializer {
        _metadata = IHyperCertMetadata(metadataAddress);

        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
    }

    /*******************
     * PUBLIC
     ******************/

    /// @notice Adds a new impact scope
    /// @param text Text representing the impact scope
    /// @return id Id of the impact scope
    function addImpactScope(string memory text) public returns (bytes32 id) {
        id = _authorizeAdd(text, impactScopes);
        impactScopes[id] = text;
        emit ImpactScopeAdded(id, text);
    }

    /// @notice Adds a new right
    /// @param text Text representing the right
    /// @return id Id of the right
    function addRight(string memory text) public returns (bytes32 id) {
        id = _authorizeAdd(text, rights);
        rights[id] = text;
        emit RightAdded(id, text);
    }

    /// @notice Adds a new work scope
    /// @param text Text representing the work scope
    /// @return id Id of the work scope
    function addWorkScope(string memory text) public returns (bytes32 id) {
        id = _authorizeAdd(text, workScopes);
        workScopes[id] = text;
        emit WorkScopeAdded(id, text);
    }

    /// @notice Issues a new hypercertificate
    /// @param account Account issuing the new hypercertificate
    /// @param data Data representing the parameters of the claim
    function mint(address account, bytes calldata data) public virtual {
        // Parse data to get Claim
        (Claim memory claim, uint64[] memory fractions) = _parseData(data);
        claim.minter = msg.sender;

        _authorizeMint(account, claim);

        // Check on overlapping contributor-claims and store if success
        _storeContributorsClaims(claim.claimHash, claim.contributors);

        uint256 slot = slotCount() + 1;
        // Store impact cert
        _hyperCerts[slot] = claim;

        // Mint impact cert
        uint256 len = fractions.length;
        for (uint256 i = 0; i < len; i++) {
            _mintValue(account, slot, fractions[i]);
        }

        emit ImpactClaimed(slot, account, fractions);
    }

    function split(uint256 tokenId, uint256[] calldata amounts) public {
        if (!_exists(tokenId)) revert NonExistentToken(tokenId);

        uint256 total;

        uint256 amountsLength = amounts.length;
        if (amounts.length == 1) revert AlreadyMinted(tokenId);

        for (uint256 i; i < amountsLength; i++) {
            total += amounts[i];
        }

        if (total > balanceOf(tokenId) || total < balanceOf(tokenId)) revert InvalidInput();

        uint256 len = amounts.length;
        for (uint256 i = 1; i < len; i++) {
            _splitValue(tokenId, amounts[i]);
        }
    }

    function merge(uint256[] memory tokenIds) public {
        uint256 len = tokenIds.length;
        uint256 targetTokenId = tokenIds[len - 1];
        for (uint256 i = 0; i < len; i++) {
            uint256 tokenId = tokenIds[i];
            if (tokenId != targetTokenId) {
                _mergeValue(tokenId, targetTokenId);
                _burn(tokenId);
            }
        }
    }

    /// @notice Gets the impact claim with the specified id
    /// @param claimID Id of the claim
    /// @return The claim, if it doesn't exist with default values
    function getImpactCert(uint256 claimID) public view returns (Claim memory) {
        return _hyperCerts[claimID];
    }

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
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC3525SlotEnumerableUpgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function name() public pure override returns (string memory) {
        return NAME;
    }

    function symbol() public pure override returns (string memory) {
        return SYMBOL;
    }

    function valueDecimals() public view virtual override returns (uint8) {
        return DECIMALS;
    }

    function getHash(
        uint64[2] memory workTimeframe_,
        bytes32[] memory workScopes_,
        uint64[2] memory impactTimeframe_,
        bytes32[] memory impactScopes_
    ) public pure virtual returns (bytes32) {
        return keccak256(abi.encode(workTimeframe_, workScopes_, impactTimeframe_, impactScopes_));
    }

    function slotURI(uint256 slotId_) external view override returns (string memory) {
        if (!_hyperCerts[slotId_].exists) {
            revert NonExistentSlot(slotId_);
        }
        return _metadata.generateSlotURI(slotId_);
    }

    function tokenURI(uint256 tokenId_) public view override returns (string memory) {
        return _metadata.generateTokenURI(slotOf(tokenId_), tokenId_);
    }

    function contractURI() public view override returns (string memory) {
        return _metadata.generateContractURI();
    }

    function burn(uint256 tokenId_) public {
        Claim storage claim = _hyperCerts[slotOf(tokenId_)];
        if (msg.sender != claim.minter) {
            revert NotApprovedOrOwner();
        }

        if (balanceOf(tokenId_) != claim.totalUnits) {
            revert InsufficientBalance(claim.totalUnits, balanceOf(tokenId_));
        }

        _burn(tokenId_);
        claim.exists = false;
    }

    function donate(uint256 tokenId_) public {
        if (msg.sender == ownerOf(tokenId_)) {
            revert NotApprovedOrOwner();
        }

        _burn(tokenId_);
    }

    /*******************
     * INTERNAL
     ******************/

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

    /// @notice Pre-add validation checks
    /// @param text Text to be added
    /// @param map Storage mapping that will be appended
    function _authorizeAdd(string memory text, mapping(bytes32 => string) storage map)
        internal
        view
        virtual
        returns (bytes32 id)
    {
        if (bytes(text).length == 0) {
            revert EmptyInput();
        }
        id = keccak256(abi.encode(text));
        if (_hasKey(map, id)) {
            revert DuplicateScope();
        }
    }

    /// @notice Pre-mint validation checks
    /// @param account Destination address for the mint
    /// @param claim Impact claim data
    /* solhint-disable code-complexity */

    function _authorizeMint(address account, Claim memory claim) internal view virtual {
        if (account == address(0)) {
            revert ToZeroAddress();
        }
        if (claim.workTimeframe[0] > claim.workTimeframe[1]) {
            revert InvalidTimeframe(claim.workTimeframe[0], claim.workTimeframe[1]);
        }
        if (claim.impactTimeframe[0] > claim.impactTimeframe[1]) {
            revert InvalidTimeframe(claim.impactTimeframe[0], claim.impactTimeframe[1]);
        }
        if (claim.workTimeframe[0] > claim.impactTimeframe[0]) {
            revert InvalidTimeframe(claim.workTimeframe[0], claim.impactTimeframe[0]);
        }

        uint256 impactScopelength = claim.impactScopes.length;
        for (uint256 i = 0; i < impactScopelength; i++) {
            if (bytes(impactScopes[claim.impactScopes[i]]).length == 0) {
                revert InvalidScope();
            }
        }

        uint256 workScopelength = claim.workScopes.length;
        for (uint256 i = 0; i < workScopelength; i++) {
            if (!_hasKey(workScopes, claim.workScopes[i])) {
                revert InvalidScope();
            }
        }
    }

    /* solhint-enable code-complexity */

    /// @notice Parse bytes to Claim and URI
    /// @param data Byte data representing the claim
    /// @dev This function is overridable in order to support future schema changes
    /// @return claim The parsed Claim struct
    /// @return Claim metadata URI
    function _parseData(bytes calldata data) internal pure virtual returns (Claim memory claim, uint64[] memory) {
        if (data.length == 0) {
            revert EmptyInput();
        }

        (
            bytes32[] memory rights_,
            bytes32[] memory workScopes_,
            bytes32[] memory impactScopes_,
            uint64[2] memory workTimeframe,
            uint64[2] memory impactTimeframe,
            address[] memory contributors,
            string memory name_,
            string memory description_,
            string memory uri_,
            uint64[] memory fractions
        ) = abi.decode(
                data,
                (bytes32[], bytes32[], bytes32[], uint64[2], uint64[2], address[], string, string, string, uint64[])
            );

        claim.claimHash = getHash(workTimeframe, workScopes_, impactTimeframe, impactScopes_);
        claim.contributors = contributors;
        claim.workTimeframe = workTimeframe;
        claim.impactTimeframe = impactTimeframe;
        claim.workScopes = workScopes_;
        claim.impactScopes = impactScopes_;
        claim.rights = rights_;
        claim.totalUnits = fractions.getSum();
        claim.version = uint16(0);
        claim.exists = true;
        claim.name = name_;
        claim.description = description_;
        claim.uri = uri_;

        return (claim, fractions);
    }

    /// @notice Stores contributor claims in the `contributorImpacts` mapping; guards against overlapping claims
    /// @param claimHash Claim data hash-code value
    /// @param creators Array of addresses for contributors
    function _storeContributorsClaims(bytes32 claimHash, address[] memory creators) internal {
        for (uint256 i = 0; i < creators.length; i++) {
            if (_contributorImpacts[creators[i]][claimHash]) {
                revert ConflictingClaim();
            }
            _contributorImpacts[creators[i]][claimHash] = true;
        }
    }

    /// @notice Checks whether the supplied mapping contains the supplied key
    /// @param map mapping to search
    /// @param key key to search
    /// @return true, if the key exists in the mapping
    function _hasKey(mapping(bytes32 => string) storage map, bytes32 key) internal view returns (bool) {
        return (bytes(map[key]).length > 0);
    }

    function _msgSender() internal view override(ContextUpgradeable, ERC3525Upgradeable) returns (address sender) {
        return msg.sender;
    }

    function setMetadataGenerator(address metadataGenerator) external onlyRole(UPGRADER_ROLE) {
        if (metadataGenerator == address(0)) {
            revert ToZeroAddress();
        }
        _metadata = IHyperCertMetadata(metadataGenerator);
    }
}
