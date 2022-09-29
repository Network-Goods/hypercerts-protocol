// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "./ERC3525Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

/// @title Hypercertificate minting logic
/// @notice Contains functions and events to initialize and issue a hypercertificate
/// @author bitbeckers, mr_bluesky
contract HypercertMinterV0 is ERC3525Upgradeable, AccessControlUpgradeable, UUPSUpgradeable {
    /// @notice Contract name
    string public constant NAME = "Hypercerts";
    /// @notice Token symbol
    string public constant SYMBOL = "HCRT";
    /// @notice Token value decimals
    uint8 public constant DECIMALS = 0;
    /// @notice User role required in order to upgrade the contract
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    /// @notice Current version of the contract
    uint16 internal _version;
    /// @notice Counter incremented and used for the next token ID
    uint256 internal _tokenId;
    /// @notice Counter incremented and used for the next slot
    uint256 internal _slot;

    /// @notice Mapping of id's to work-scopes
    mapping(bytes32 => string) public workScopes;
    /// @notice Mapping of id's to impact-scopes
    mapping(bytes32 => string) public impactScopes;
    /// @notice Mapping of id's to rights
    mapping(bytes32 => string) public rights;
    mapping(address => mapping(bytes32 => bool)) internal _contributorImpacts;
    mapping(uint256 => Claim) internal _impactCerts;

    struct Claim {
        bytes32 claimHash;
        uint64[2] workTimeframe;
        uint64[2] impactTimeframe;
        bytes32[] workScopes;
        bytes32[] impactScopes;
        bytes32[] rights;
        address[] contributors;
        uint8[] fractions;
        uint16 version;
        bool exists;
    }

    /*******************
     * EVENTS
     ******************/

    /// @notice Emitted when an impact is claimed.
    /// @param id Id of the claimed impact.
    /// @param minter Address of cert minter.
    /// @param claimHash Hash value of the claim data.
    /// @param contributors Contributors to the claimed impact.
    /// @param workTimeframe To/from date of the work related to the claim.
    /// @param impactTimeframe To/from date of the claimed impact.
    /// @param workScopes Id's relating to the scope of the work.
    /// @param impactScopes Id's relating to the scope of the impact.
    /// @param rights Id's relating to the rights applied to the hypercert.
    /// @param fractions Units of tokens issued under the hypercert.
    /// @param version Version of the hypercert.
    /// @param uri URI of the metadata of the hypercert.
    event ImpactClaimed(
        uint256 id,
        address minter,
        bytes32 claimHash,
        address[] contributors,
        uint64[2] workTimeframe,
        uint64[2] impactTimeframe,
        bytes32[] workScopes,
        bytes32[] impactScopes,
        bytes32[] rights,
        uint8[] fractions,
        uint64 version,
        string uri
    );

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
    function initialize() public override initializer {
        __ERC3525_init(NAME, SYMBOL, DECIMALS);
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
    function mint(address account, bytes memory data) public virtual {
        // Parse data to get Claim
        (Claim memory claim, string memory tokenURI_) = _parseData(data);

        _authorizeMint(account, claim);

        // Check on overlapping contributor-claims and store if success
        _storeContributorsClaims(claim.claimHash, claim.contributors);

        _slot++;
        // Store impact cert
        _impactCerts[_slot] = claim;

        // Mint impact cert
        // _safeMint(account, tokenId, data);
        uint256 l = claim.fractions.length;
        for (uint256 i = 0; i < l; i++) {
            _tokenId++;
            _mintValue(account, _tokenId, _slot, claim.fractions[i]);
            _setTokenURI(_tokenId, tokenURI_);
        }

        emit ImpactClaimed(
            _slot,
            account,
            claim.claimHash,
            claim.contributors,
            claim.workTimeframe,
            claim.impactTimeframe,
            claim.workScopes,
            claim.impactScopes,
            claim.rights,
            claim.fractions,
            claim.version,
            tokenURI_
        );
    }

    /// @notice Gets the impact claim with the specified id
    /// @param claimID Id of the claim
    /// @return The claim, if it doesn't exist with default values
    function getImpactCert(uint256 claimID) public view returns (Claim memory) {
        return _impactCerts[claimID];
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
        override(ERC3525Upgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
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
        require(bytes(text).length > 0, "empty text");
        id = keccak256(abi.encode(text));
        require(!_hasKey(map, id), "already exists");
    }

    /// @notice Pre-mint validation checks
    /// @param account Destination address for the mint
    /// @param claim Impact claim data
    function _authorizeMint(address account, Claim memory claim) internal view virtual {
        require(account != address(0), "Mint: mint to the zero address");
        require(claim.workTimeframe[0] <= claim.workTimeframe[1], "Mint: invalid workTimeframe");
        require(claim.impactTimeframe[0] <= claim.impactTimeframe[1], "Mint: invalid impactTimeframe");
        require(claim.workTimeframe[0] <= claim.impactTimeframe[0], "Mint: impactTimeframe prior to workTimeframe");

        uint256 impactScopelength = claim.impactScopes.length;
        for (uint256 i = 0; i < impactScopelength; i++) {
            require(_hasKey(impactScopes, claim.impactScopes[i]), "Mint: invalid impact scope");
        }

        uint256 workScopelength = claim.workScopes.length;
        for (uint256 i = 0; i < workScopelength; i++) {
            require(_hasKey(workScopes, claim.workScopes[i]), "Mint: invalid work scope");
        }
    }

    /// @notice Parse bytes to Claim and URI
    /// @param data Byte data representing the claim
    /// @dev This function is overridable in order to support future schema changes
    /// @return claim The parsed Claim struct
    /// @return Claim metadata URI
    function _parseData(bytes memory data) internal pure virtual returns (Claim memory claim, string memory) {
        require(data.length > 0, "_parseData: input data empty");

        (
            bytes32[] memory rights_,
            bytes32[] memory workScopes_,
            bytes32[] memory impactScopes_,
            uint64[2] memory workTimeframe,
            uint64[2] memory impactTimeframe,
            address[] memory contributors,
            string memory uri_,
            uint8[] memory fractions
        ) = abi.decode(data, (bytes32[], bytes32[], bytes32[], uint64[2], uint64[2], address[], string, uint8[]));

        bytes32 claimHash = keccak256(abi.encode(workTimeframe, workScopes_, impactTimeframe, impactScopes_));

        claim.claimHash = claimHash;
        claim.contributors = contributors;
        claim.workTimeframe = workTimeframe;
        claim.impactTimeframe = impactTimeframe;
        claim.workScopes = workScopes_;
        claim.impactScopes = impactScopes_;
        claim.rights = rights_;
        claim.fractions = fractions;
        claim.version = uint16(0);
        claim.exists = true;

        return (claim, uri_);
    }

    /// @notice Stores contributor claims in the `contributorImpacts` mapping; guards against overlapping claims
    /// @param claimHash Claim data hash-code value
    /// @param creators Array of addresses for contributors
    function _storeContributorsClaims(bytes32 claimHash, address[] memory creators) internal {
        for (uint256 i = 0; i < creators.length; i++) {
            require(!_contributorImpacts[creators[i]][claimHash], "Claim: claim for creators overlapping");
            _contributorImpacts[creators[i]][claimHash] = true;
        }
    }

    /// @notice Hash the specified string value
    /// @param value string to hash
    /// @return a keccak256 hash-code
    function _hash(string memory value) internal pure returns (bytes32) {
        return keccak256(abi.encode(value));
    }

    /// @notice Checks whether the supplied mapping contains the supplied key
    /// @param map mapping to search
    /// @param key key to search
    /// @return true, if the key exists in the mapping
    function _hasKey(mapping(bytes32 => string) storage map, bytes32 key) internal view returns (bool) {
        return (bytes(map[key]).length > 0);
    }
}
