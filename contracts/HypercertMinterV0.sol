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

/// @title Hypercert Minting logic
/// @notice Contains functions and events to initialize and issue a hypercert
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
    uint16 internal _version;
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    uint256 public counter;

    mapping(bytes32 => string) public workScopes;
    mapping(bytes32 => string) public impactScopes;
    mapping(bytes32 => string) public rights;
    mapping(address => mapping(bytes32 => bool)) public contributorImpacts;
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
    /// @notice constructor
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @notice Initializes the hypercert.
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
    /// @notice adds a new impact scope
    /// @param text text representing the impact scope
    /// @return id id of the impact scope
    function addImpactScope(string memory text) public returns (bytes32 id) {
        require(bytes(text).length > 0, "addImpactScope: empty text");
        id = _hash(text);
        require(!_hasKey(impactScopes, id), "addImpactScope: already exists");
        impactScopes[id] = text;
        emit ImpactScopeAdded(id, text);
    }

    /// @notice adds a new right
    /// @param text text representing the right
    /// @return id id of the right
    function addRight(string memory text) public returns (bytes32 id) {
        require(bytes(text).length > 0, "addRight: empty text");
        id = _hash(text);
        require(!_hasKey(rights, id), "addRight: already exists");
        rights[id] = text;
        emit RightAdded(id, text);
    }

    /// @notice adds a new work scope
    /// @param text text representing the work scope
    /// @return id id of the work scope
    function addWorkScope(string memory text) public returns (bytes32 id) {
        require(bytes(text).length > 0, "addWorkScope: empty text");
        id = _hash(text);
        require(!_hasKey(workScopes, id), "addWorkScope: already exists");
        workScopes[id] = text;
        emit WorkScopeAdded(id, text);
    }

    /// @notice mints a new hypercert
    /// @param account account minting the new hypercert
    /// @param amount amount of the new token to mint
    /// @param data data representing the parameters of the new hypercert
    function mint(
        address account,
        uint256 amount,
        bytes memory data
    ) public {
        require(account != address(0), "Mint: mint to the zero address");
        require(data.length > 0, "Mint: input data empty");

        // Parse data to get Claim
        uint256 _v = version();

        (
            bytes32[] memory _rights,
            bytes32[] memory _workScopes,
            bytes32[] memory _impactScopes,
            uint256[2] memory _workTimeframe,
            uint256[2] memory _impactTimeframe,
            address[] memory _contributors,
            string memory _uri
        ) = abi.decode(data, (bytes32[], bytes32[], bytes32[], uint256[2], uint256[2], address[], string));

        bytes32 _claimHash = keccak256(abi.encode(_workTimeframe, _workScopes, _impactTimeframe, _impactScopes, _v));

        for (uint256 i = 0; i < _impactScopes.length; i++) {
            require(_hasKey(impactScopes, _impactScopes[i]), "Mint: invalid impact scope");
        }

        for (uint256 i = 0; i < _workScopes.length; i++) {
            require(_hasKey(workScopes, _workScopes[i]), "Mint: invalid work scope");
        }

        // Check on overlapping contributor-claims and store if success
        _storeContributorsClaims(_claimHash, _contributors);

        Claim memory _claim;
        _claim.claimHash = _claimHash;
        _claim.contributors = _contributors;
        _claim.workTimeframe = _workTimeframe;
        _claim.impactTimeframe = _impactTimeframe;
        _claim.workScopes = _workScopes;
        _claim.impactScopes = _impactScopes;
        _claim.rights = _rights;
        _claim.version = _v;
        _claim.exists = true;

        // Store impact cert
        impactCerts[counter] = _claim;
        _setURI(counter, _uri);

        // Mint impact cert
        _mint(account, counter, amount, data);

        emit ImpactClaimed(
            counter,
            _claim.claimHash,
            _claim.contributors,
            _claim.workTimeframe,
            _claim.impactTimeframe,
            _claim.workScopes,
            _claim.impactScopes,
            _claim.rights,
            _claim.version,
            _uri
        );

        counter += 1;
    }

    /// @notice gets the hypercert with the specified id
    /// @param claimID id of the claim
    function getImpactCert(uint256 claimID) public view returns (Claim memory) {
        return impactCerts[claimID];
    }

    /// @notice gets the URI of the token with the specified id
    /// @param tokenId id of the token
    function uri(uint256 tokenId)
        public
        view
        override(ERC1155Upgradeable, ERC1155URIStorageUpgradeable)
        returns (string memory)
    {
        return super.uri(tokenId);
    }

    /// @notice gets the current version of the contract
    function version() public pure virtual returns (uint256) {
        return 0;
    }

    /// @notice returns a flag indicating if the contract supports the specified interface
    /// @param interfaceId id of the interface
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

    // solhint-disable-next-line no-empty-blocks
    function _authorizeUpgrade(address newImplementation) internal override onlyRole(UPGRADER_ROLE) {
        //empty block
    }

    // The following functions are overrides required by Solidity.
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

    function _storeContributorsClaims(bytes32 claimHash, address[] memory creators) internal {
        for (uint256 i = 0; i < creators.length; i++) {
            require(!contributorImpacts[creators[i]][claimHash], "Claim: claim for creators overlapping");
            contributorImpacts[creators[i]][claimHash] = true;
        }
    }

    function _hash(string memory value) internal pure returns (bytes32) {
        return keccak256(abi.encode(value));
    }

    function _hasKey(mapping(bytes32 => string) storage map, bytes32 key) internal view returns (bool) {
        return (bytes(map[key]).length > 0);
    }
}
