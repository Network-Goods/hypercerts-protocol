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
    mapping(address => mapping(bytes32 => bool)) public contributorImpacts;
    mapping(uint256 => Claim) internal impactCerts;

    struct Claim {
        bytes32 claimHash;
        uint256 rights;
        uint256[2] workTimeframe;
        uint256[2] impactTimeframe;
        address[] contributors;
        uint256[] workScopes;
        uint256[] impactScopes;
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
        uint256[] workScopes,
        uint256[] impactScopes,
        uint256 version,
        string uri
    );

    event ImpactBurned(uint256 impactCertID);

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

    function mint(
        address account,
        uint256 amount,
        bytes memory data
    ) public {
        require(account != address(0), "Mint: mint to the zero address");

        // Parse data to get Claim
        (Claim memory claim, string memory _uri, bytes32 claimHash) = _bytesToClaimAndURI(data);

        // Check on overlapping contributor-claims and store if success
        _storeContributorsClaims(claimHash, claim.contributors);

        // Store impact cert
        impactCerts[counter] = claim;
        _setURI(counter, _uri);

        // Mint impact cert
        _mint(account, counter, amount, data);
        emit ImpactClaimed(
            counter,
            claimHash,
            claim.contributors,
            claim.workTimeframe,
            claim.impactTimeframe,
            claim.workScopes,
            claim.impactScopes,
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

    function _storeContributorsClaims(bytes32 claimHash, address[] memory creators) internal {
        for (uint256 i = 0; i < creators.length; i++) {
            require(!contributorImpacts[creators[i]][claimHash], "Claim: claim for creators overlapping");
            contributorImpacts[creators[i]][claimHash] = true;
        }
    }

    // Mapped bytes object to claim
    function _bytesToClaimAndURI(bytes memory data)
        internal
        pure
        returns (
            Claim memory,
            string memory,
            bytes32
        )
    {
        require(data.length > 0, "Parse: input data empty");
        uint256 _v = version();

        (
            uint256 _rights,
            uint256[2] memory _workTimeframe,
            uint256[2] memory _impactTimeframe,
            address[] memory _contributors,
            uint256[] memory _workScopes,
            uint256[] memory _impactScopes,
            string memory _uri
        ) = abi.decode(data, (uint256, uint256[2], uint256[2], address[], uint256[], uint256[], string));

        bytes32 _claimHash = keccak256(abi.encode(_workTimeframe, _workScopes, _impactTimeframe, _impactScopes, _v));

        Claim memory _claim = Claim(
            _claimHash,
            _rights,
            _workTimeframe,
            _impactTimeframe,
            _contributors,
            _workScopes,
            _impactScopes,
            _v,
            true
        );
        return (_claim, _uri, _claimHash);
    }
}
