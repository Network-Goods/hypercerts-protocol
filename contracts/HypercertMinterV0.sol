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

    mapping(uint256 => string) public workScopes;
    mapping(uint256 => string) public impactScopes;
    mapping(uint256 => string) public rights;
    mapping(address => mapping(uint256 => bool)) public contributorImpacts;
    mapping(uint256 => Claim) internal impactCerts;

    struct Claim {
        uint256 claimHash;
        address[] contributors;
        uint256[2] workTimeframe;
        uint256[2] impactTimeframe;
        uint256[] workScopes;
        uint256[] impactScopes;
        uint256[] rights;
        uint256 version;
        bool exists;
    }

    /*******************
     * EVENTS
     ******************/

    event ImpactClaimed(
        uint256 indexed id,
        uint256 indexed claimHash,
        address[] contributors,
        uint256[2] workTimeframe,
        uint256[2] impactTimeframe,
        uint256[] workScopes,
        uint256[] impactScopes,
        uint256[] rights,
        uint256 version,
        string uri
    );

    event ImpactScopeAdded(uint256 indexed id, string indexed text);

    event RightAdded(uint256 indexed id, string indexed text);

    event WorkScopeAdded(uint256 indexed id, string indexed text);

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

    function addImpactScope(string memory text) public returns (uint256 id) {
        require(bytes(text).length > 0, "addImpactScope: empty text");
        id = _hash(text);
        require(!_hasKey(impactScopes, id), "addImpactScope: already exists");
        impactScopes[id] = text;
        emit ImpactScopeAdded(id, text);
    }

    function addRight(string memory text) public returns (uint256 id) {
        require(bytes(text).length > 0, "addRight: empty text");
        id = _hash(text);
        require(!_hasKey(rights, id), "addRight: already exists");
        rights[id] = text;
        emit RightAdded(id, text);
    }

    function addWorkScope(string memory text) public returns (uint256 id) {
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

        // Parse data to get Claim
        (Claim memory claim, string memory _uri) = _bytesToClaimAndURI(data);

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
        _setURI(counter, _uri);

        // Mint impact cert
        _mint(account, counter, amount, data);
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

    function _storeContributorsClaims(uint256 claimHash, address[] memory creators) internal {
        for (uint256 i = 0; i < creators.length; i++) {
            require(!contributorImpacts[creators[i]][claimHash], "Claim: claim for creators overlapping");
            contributorImpacts[creators[i]][claimHash] = true;
        }
    }

    // Mapped bytes object to claim
    function _bytesToClaimAndURI(bytes memory data) internal pure returns (Claim memory, string memory) {
        require(data.length > 0, "Parse: input data empty");
        uint256 _v = version();

        (
            uint256[] memory _rights,
            uint256[] memory _workScopes,
            uint256[] memory _impactScopes,
            uint256[2] memory _workTimeframe,
            uint256[2] memory _impactTimeframe,
            address[] memory _contributors,
            string memory _uri
        ) = abi.decode(data, (uint256[], uint256[], uint256[], uint256[2], uint256[2], address[], string));

        uint256 _claimHash = uint256(
            keccak256(abi.encode(_workTimeframe, _workScopes, _impactTimeframe, _impactScopes, _v))
        );

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

        return (_claim, _uri);
    }

    function _hash(string memory value) internal pure returns (uint256) {
        return uint256(keccak256(abi.encode(value)));
    }

    function _hasKey(mapping(uint256 => string) storage map, uint256 key) internal view returns (bool) {
        return (bytes(map[key]).length > 0);
    }
}
