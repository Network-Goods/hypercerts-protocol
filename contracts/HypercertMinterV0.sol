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

    event ImpactScopeAdded(bytes32 id, string text);

    event RightAdded(bytes32 id, string text);

    event WorkScopeAdded(bytes32 id, string text);

    /*******************
     * DEPLOY
     ******************/

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

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

    function addImpactScope(string memory text) public returns (bytes32 id) {
        require(bytes(text).length > 0, "addImpactScope: empty text");
        id = _hash(text);
        require(!_hasKey(impactScopes, id), "addImpactScope: already exists");
        impactScopes[id] = text;
        emit ImpactScopeAdded(id, text);
    }

    function addRight(string memory text) public returns (bytes32 id) {
        require(bytes(text).length > 0, "addRight: empty text");
        id = _hash(text);
        require(!_hasKey(rights, id), "addRight: already exists");
        rights[id] = text;
        emit RightAdded(id, text);
    }

    function addWorkScope(string memory text) public returns (bytes32 id) {
        require(bytes(text).length > 0, "addWorkScope: empty text");
        id = _hash(text);
        require(!_hasKey(workScopes, id), "addWorkScope: already exists");
        workScopes[id] = text;
        emit WorkScopeAdded(id, text);
    }

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

    function getImpactCert(uint256 claimID) public view returns (Claim memory) {
        return impactCerts[claimID];
    }

    function uri(uint256 tokenId)
        public
        view
        override(ERC1155Upgradeable, ERC1155URIStorageUpgradeable)
        returns (string memory)
    {
        return super.uri(tokenId);
    }

    function version() public pure virtual returns (uint256) {
        return 0;
    }

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
