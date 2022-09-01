// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155SupplyUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "hardhat/console.sol";

/// @title Hypercertificate minting logic
/// @notice Contains functions and events to initialize and issue a hypercertificate
/// @author bitbeckers, mr_bluesky
contract HypercertMinterV0 is
    Initializable,
    ERC1155Upgradeable,
    AccessControlUpgradeable,
    ERC1155BurnableUpgradeable,
    ERC1155SupplyUpgradeable,
    ERC1155URIStorageUpgradeable,
    UUPSUpgradeable
{
    /// @notice Current version of the contract
    uint16 internal _version;
    /// @notice User role required in order to upgrade the contract
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    /// @notice Counter incremented to form the hypercertificate Id
    uint256 public counter;

    /// @notice Mapping of id's to work-scopes
    mapping(bytes32 => string) public workScopes;
    /// @notice Mapping of id's to impact-scopes
    mapping(bytes32 => string) public impactScopes;
    /// @notice Mapping of id's to rights
    mapping(bytes32 => string) public rights;
    /// @notice Mapping of contributor addresses to impact-scopes
    mapping(address => mapping(bytes32 => bool)) public contributorImpacts;
    /// @notice Mapping of id's to hypercertificates
    mapping(uint256 => Claim) internal impactCerts;

    struct Claim {
        bytes32 claimHash;
        address[] contributors;
        uint256[2] workTimeframe;
        uint256[2] impactTimeframe;
        bytes32[] workScopes;
        bytes32[] impactScopes;
        bytes32[] rights;
        uint256 version;
        bool exists;
    }

    /*******************
     * EVENTS
     ******************/

    /// @notice Emitted when an impact is claimed.
    /// @param id Id of the claimed impact.
    /// @param claimHash Hash value of the claim data.
    /// @param contributors Contributors to the claimed impact.
    /// @param workTimeframe To/from date of the work related to the claim.
    /// @param impactTimeframe To/from date of the claimed impact.
    /// @param workScopes Id's relating to the scope of the work.
    /// @param impactScopes Id's relating to the scope of the impact.
    /// @param rights Id's relating to the rights applied to the hypercert.
    /// @param version Version of the hypercert.
    /// @param uri URI of the metadata of the hypercert.
    event ImpactClaimed(
        uint256 id,
        bytes32 claimHash,
        address[] contributors,
        uint256[2] workTimeframe,
        uint256[2] impactTimeframe,
        bytes32[] workScopes,
        bytes32[] impactScopes,
        bytes32[] rights,
        uint256 version,
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
    function initialize() public initializer {
        __ERC1155_init("");
        __AccessControl_init();
        __ERC1155Burnable_init();
        __ERC1155URIStorage_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
        _version = 0;
        counter = 0;
    }

    /*******************
     * PUBLIC
     ******************/
    /// @notice Adds a new impact scope
    /// @param text Text representing the impact scope
    /// @return id Id of the impact scope
    function addImpactScope(string memory text) public returns (bytes32 id) {
        require(bytes(text).length > 0, "addImpactScope: empty text");
        id = _hash(text);
        require(!_hasKey(impactScopes, id), "addImpactScope: already exists");
        impactScopes[id] = text;
        emit ImpactScopeAdded(id, text);
    }

    /// @notice Adds a new right
    /// @param text Text representing the right
    /// @return id Id of the right
    function addRight(string memory text) public returns (bytes32 id) {
        require(bytes(text).length > 0, "addRight: empty text");
        id = _hash(text);
        require(!_hasKey(rights, id), "addRight: already exists");
        rights[id] = text;
        emit RightAdded(id, text);
    }

    /// @notice Adds a new work scope
    /// @param text Text representing the work scope
    /// @return id Id of the work scope
    function addWorkScope(string memory text) public returns (bytes32 id) {
        require(bytes(text).length > 0, "addWorkScope: empty text");
        id = _hash(text);
        require(!_hasKey(workScopes, id), "addWorkScope: already exists");
        workScopes[id] = text;
        emit WorkScopeAdded(id, text);
    }

    /// @notice Issues a new hypercertificate
    /// @param account Account issuing the new hypercertificate
    /// @param amount Amount of the new hypercertificate to mint
    /// @param data Data representing the parameters of the claim
    function mint(
        address account,
        uint256 amount,
        bytes memory data
    ) public {
        require(account != address(0), "Mint: mint to the zero address");
        require(data.length > 0, "Mint: input data empty");

        // Parse data to get Claim
        (Claim memory claim, string memory uri_) = _parseData(data);

        require(claim.workTimeframe[0] <= claim.workTimeframe[1], "Mint: invalid workTimeframe");
        require(claim.impactTimeframe[0] <= claim.impactTimeframe[1], "Mint: invalid impactTimeframe");
        require(claim.workTimeframe[0] <= claim.impactTimeframe[0], "Mint: impactTimeframe prior to workTimeframe");

        for (uint256 i = 0; i < claim.impactScopes.length; i++) {
            require(_hasKey(impactScopes, claim.impactScopes[i]), "Mint: invalid impact scope");
        }

        for (uint256 i = 0; i < claim.workScopes.length; i++) {
            require(_hasKey(workScopes, claim.workScopes[i]), "Mint: invalid work scope");
        }

        // Check on overlapping contributor-claims and store if success
        _storeContributorsClaims(claim.claimHash, claim.contributors);

        // Store impact cert
        impactCerts[counter] = claim;
        _setURI(counter, uri_);

        // Mint impact cert
        _mint(account, counter, amount, data);

        // TODO surface info on owner for Graph
        emit ImpactClaimed(
            counter,
            claim.claimHash,
            claim.contributors,
            claim.workTimeframe,
            claim.impactTimeframe,
            claim.workScopes,
            claim.impactScopes,
            claim.rights,
            claim.version,
            uri_
        );

        counter += 1;
    }

    /// @notice Gets the impact claim with the specified id
    /// @param claimID Id of the claim
    /// @return The claim, if it exists
    function getImpactCert(uint256 claimID) public view returns (Claim memory) {
        return impactCerts[claimID];
    }

    /// @notice Auto-generated by https://docs.openzeppelin.com/contracts/4.x/wizard
    /// @param tokenId Id of the token
    /// @dev Selects which base implementation to call
    /// @return URI of the token
    function uri(uint256 tokenId)
        public
        view
        override(ERC1155Upgradeable, ERC1155URIStorageUpgradeable)
        returns (string memory)
    {
        return super.uri(tokenId);
    }

    /// @notice Gets the current version of the contract
    /// @return Version of the contract
    function version() public pure virtual returns (uint256) {
        return 0;
    }

    /// @notice Returns a flag indicating if the contract supports the specified interface
    /// @param interfaceId Id of the interface
    /// @return true, if the interface is supported
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155Upgradeable, AccessControlUpgradeable)
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

    /// @notice auto-generated by https://docs.openzeppelin.com/contracts/4.x/wizard
    /// @dev selects which base implementation to call
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override(ERC1155Upgradeable, ERC1155SupplyUpgradeable) {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    /// @notice Parse bytes to Claim and URI
    /// @param data Byte data representing the claim
    /// @dev This function is overridable in order to support future schema changes
    /// @return claim The parsed Claim struct
    /// @return Claim metadata URI
    function _parseData(bytes memory data) internal pure virtual returns (Claim memory claim, string memory) {
        require(data.length > 0, "_parseData: input data empty");

        uint256 v = version();

        (
            bytes32[] memory rights_,
            bytes32[] memory workScopes_,
            bytes32[] memory impactScopes_,
            uint256[2] memory workTimeframe,
            uint256[2] memory impactTimeframe,
            address[] memory contributors,
            string memory uri_
        ) = abi.decode(data, (bytes32[], bytes32[], bytes32[], uint256[2], uint256[2], address[], string));

        bytes32 claimHash = keccak256(abi.encode(workTimeframe, workScopes_, impactTimeframe, impactScopes_, v));

        claim.claimHash = claimHash;
        claim.contributors = contributors;
        claim.workTimeframe = workTimeframe;
        claim.impactTimeframe = impactTimeframe;
        claim.workScopes = workScopes_;
        claim.impactScopes = impactScopes_;
        claim.rights = rights_;
        claim.version = v;
        claim.exists = true;

        return (claim, uri_);
    }

    /// @notice Stores contributor claims in the `contributorImpacts` mapping; guards against overlapping claims
    /// @param claimHash Claim data hash-code value
    /// @param creators Array of addresses for contributors
    function _storeContributorsClaims(bytes32 claimHash, address[] memory creators) internal {
        for (uint256 i = 0; i < creators.length; i++) {
            require(!contributorImpacts[creators[i]][claimHash], "Claim: claim for creators overlapping");
            contributorImpacts[creators[i]][claimHash] = true;
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
