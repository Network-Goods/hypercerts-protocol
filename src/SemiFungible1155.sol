// SPDX-License-Identifier: MIT
// Used components of Enjin example implementation for mixed fungibility
// https://github.com/enjin/erc-1155/blob/master/contracts/ERC1155MixedFungibleMintable.sol
pragma solidity ^0.8.9;

import { Upgradeable1155 } from "./Upgradeable1155.sol";
import { IERC1155ReceiverUpgradeable } from "oz-upgradeable/token/ERC1155/IERC1155ReceiverUpgradeable.sol";
import "forge-std/console2.sol";

// TODO shared error lib
error ArraySize();
error ToZeroAddress();
error NotApprovedOrOwner();
error NotAllowed();
error TypeMismatch();
error FractionalBurn();

/// @title Contract for minting semi-fungible EIP1155 tokens
/// @author bitbeckers
/// @notice Extends { Upgradeable1155 } token with semi-fungible properties and the concept of `units`
/// @dev Adds split bit strategy as described in [EIP-1155](https://eips.ethereum.org/EIPS/eip-1155#non-fungible-tokens)
contract SemiFungible1155 is Upgradeable1155 {
    /// @dev Counter used to generate next typeID.
    uint256 public typeCounter;

    /// @dev Bitmask used to expose only upper 128 bits of uint256
    uint256 public constant TYPE_MASK = uint256(uint128(int128(~0))) << 128;

    /// @dev Bitmask used to expose only lower 128 bits of uint256
    uint256 public constant NF_INDEX_MASK = uint128(int128(~0));

    /// @dev Identify non-fungible index. Use to find index of token belonging to `typeID`
    uint256 public constant TYPE_NF_BIT = uint256(1 << 255);

    /// @dev Mapping of `tokenID` to address of `owner`
    mapping(uint256 => address) internal owners;

    /// @dev Mapping of `tokenID` to address of `creator`
    mapping(uint256 => address) internal creators; //TODO extend with admin contracts

    /// @dev Used to determine amount of `units` stored in token at `tokenID`
    mapping(uint256 => uint256) internal tokenValues;

    /// @dev Used to find highest index of token belonging to token at `typeID`
    // TODO should have max value type(uint256).max
    mapping(uint256 => uint256) internal maxIndex;

    /// @dev Mapping from `tokenID` to user at `address` to get `units` owned
    mapping(uint256 => mapping(address => uint256)) internal tokenUserBalances;

    /// @dev Emitted on transfer of `value` between `fromTokenID` to `toTokenID` of the same `claimID`
    event ValueTransfer(uint256 claimID, uint256 fromTokenID, uint256 toTokenID, uint256 value);

    /// @dev Init method. Underlying { Upgradeable1155 } is `Initializable`
    // solhint-disable-next-line func-name-mixedcase
    function __SemiFungible1155_init() public virtual onlyInitializing {
        __Upgradeable1155_init();
    }

    /// ENJIN EXAMPLE IMPLEMENTATION
    // Only to make code clearer. Should not be functions
    // TODO cleanup functions
    /// @dev Identify if token at `_id` is non-fungible.
    /// @dev Non-fungible tokens are used to represent the base type for hypercert tokens
    function isNonFungible(uint256 _id) internal pure returns (bool) {
        return _id & TYPE_NF_BIT == TYPE_NF_BIT;
    }

    /// @dev Identify if token at `_id` is fungible.
    /// @dev Fungible tokens are used to represent (fractional) ownership of a claim
    function isFungible(uint256 _id) internal pure returns (bool) {
        return _id & TYPE_NF_BIT == 0;
    }

    /// @dev Get index of fractional token as `_id`
    function getNonFungibleIndex(uint256 _id) internal pure returns (uint256) {
        return _id & NF_INDEX_MASK;
    }

    /// @dev Get base type ID for token at `_id`
    function getNonFungibleBaseType(uint256 _id) internal pure returns (uint256) {
        return _id & TYPE_MASK;
    }

    /// @dev Identify that token at `_id` is base type.
    /// @dev Upper 128 bits identify base type ID, lower bits should be 0
    function isNonFungibleBaseType(uint256 _id) internal pure returns (bool) {
        // A base type has the NF bit but does not have an index.
        return (_id & TYPE_NF_BIT == TYPE_NF_BIT) && (_id & NF_INDEX_MASK == 0);
    }

    /// @dev Identify that token at `_id` is fraction of a claim.
    /// @dev Upper 128 bits identify base type ID, lower bits should be > 0
    function isNonFungibleItem(uint256 _id) internal pure returns (bool) {
        return (_id & TYPE_NF_BIT == TYPE_NF_BIT) && (_id & NF_INDEX_MASK != 0);
    }

    /// READ
    function ownerOf(uint256 tokenID) public view returns (address _owner) {
        _owner = owners[tokenID];
    }

    /// @dev see {IHypercertToken}
    function _unitsOf(uint256 tokenID) internal view returns (uint256 units) {
        units = tokenValues[tokenID];
    }

    /// @dev see {IHypercertToken}
    function _unitsOf(address account, uint256 tokenID) internal view returns (uint256 units) {
        units = 0;

        // Check if fraction token and accounts owns it
        if (getNonFungibleIndex(tokenID) != 0 && ownerOf(tokenID) == account) {
            units = tokenValues[tokenID];
        }

        return units;
    }

    /// MUTATE

    /// @dev create token type ID based of token counter
    // TODO should creator be msg.sender or submit account?
    function _createTokenType(uint256 units, string memory uri) internal returns (uint256 typeID) {
        typeID = (++typeCounter << 128); //TODO max value check?

        owners[typeID] = _msgSender();
        creators[typeID] = _msgSender();
        tokenValues[typeID] = units;

        _mint(_msgSender(), typeID, 1, "");
        _setURI(typeID, uri);
    }

    /// @dev Mint a new token type and the initial value
    function _mintValue(address _account, uint256 _value, string memory uri) internal returns (uint256 typeID) {
        if (_value == 0) {
            revert NotAllowed();
        }
        typeID = _createTokenType(_value, uri);
        maxIndex[typeID] += 1;
        uint256 tokenID = typeID + maxIndex[typeID]; //1 based indexing, 0 holds type data

        owners[tokenID] = _account;
        tokenValues[tokenID] = _value; //first fraction

        _mint(_account, tokenID, 1, "");
        emit ValueTransfer(typeID, 0, tokenID, _value);
    }

    /// @dev Mint a new token type and the initial fractions
    function _mintValue(
        address _account,
        uint256[] memory _values,
        string memory uri
    ) internal returns (uint256 typeID) {
        if (_values.length > 253) {
            //TODO determine array limits (use testing)
            revert ArraySize();
        }

        uint256 totalValue = _getSum(_values);

        typeID = _mintValue(_account, totalValue, uri);

        _splitValue(_account, typeID + maxIndex[typeID], _values);
    }

    /// @dev Mint a new token for an existing type
    function _mintClaim(uint256 _typeID, uint256 _units) internal returns (uint256 tokenID) {
        maxIndex[_typeID] += 1;
        tokenID = _typeID + maxIndex[_typeID]; //1 based indexing, 0 holds type data

        address _account = _msgSender();
        owners[tokenID] = _account;
        tokenValues[tokenID] = _units;

        _mint(_account, tokenID, 1, "");
    }

    /// @dev Split the units of `_tokenID` owned by `account` across `_values`
    /// @dev `_values` must sum to total `units` held at `_tokenID`
    function _splitValue(address _account, uint256 _tokenID, uint256[] memory _values) internal {
        if (_values.length > 253) {
            revert ArraySize();
        }

        if (getNonFungibleIndex(_tokenID) == 0) {
            revert NotAllowed();
        }

        uint256 _typeID = getNonFungibleBaseType(_tokenID);
        uint256 newFractionsStartID = maxIndex[_typeID];

        uint256 len = _values.length;
        uint256 left = tokenValues[_tokenID];

        for (uint256 i = 1; i < len; i++) {
            uint256 tokenID = _typeID + newFractionsStartID + i;

            owners[tokenID] = _account;
            tokenValues[tokenID] = _values[i];
            left -= _values[i];
            _mint(_account, tokenID, 1, ""); //TODO batchmint?
            emit ValueTransfer(_typeID, _tokenID, tokenID, _values[i]);
        }

        tokenValues[_tokenID] = left;

        maxIndex[_typeID] += len;
    }

    /// @dev Merge the units of `_fractionIDs`.
    /// @dev Base type of `_fractionIDs` must be identical for all tokens.
    // TODO optimise merge, possibly batch burn and mint 1 new?
    // TODO emit events
    function _mergeValue(uint256[] memory _fractionIDs) internal {
        if (_fractionIDs.length > 253) {
            revert ArraySize();
        }
        uint256 len = _fractionIDs.length;

        uint256 target = _fractionIDs[len - 1];
        uint256 _typeID = getNonFungibleBaseType(target);

        uint256 _totalValue = 0;
        uint256[] memory _valuesToBurn = new uint256[](len - 1);
        uint256[] memory _idsToBurn = new uint256[](len - 1);

        address _account = _msgSender();
        for (uint256 i = 0; i < len; i++) {
            if (getNonFungibleBaseType(_fractionIDs[i]) != _typeID) revert TypeMismatch();
            uint256 _fractionID = _fractionIDs[i];
            if (_fractionID != target) {
                _idsToBurn[i] = _fractionID;
                _valuesToBurn[i] = 1;
                _totalValue += tokenValues[_fractionID];

                delete owners[_fractionID];
                delete tokenValues[_fractionID];
                emit ValueTransfer(_typeID, _fractionID, target, tokenValues[_fractionID]);
            } else {
                tokenValues[_fractionID] += _totalValue;
            }
        }
        _burnBatch(_account, _idsToBurn, _valuesToBurn);
    }

    /// @dev Burn the token at `_tokenID` owned by `_account`
    /// @dev Not allowed to burn base type.
    /// @dev `_tokenID` must hold all value declared at base type
    function _burnValue(address _account, uint256 _tokenID) internal {
        uint256 _typeID = getNonFungibleBaseType(_tokenID);
        if (getNonFungibleIndex(_tokenID) == 0) revert NotAllowed();
        if (tokenValues[_tokenID] != tokenValues[_typeID]) revert FractionalBurn();

        delete owners[_typeID];
        delete owners[_tokenID];
        delete tokenValues[_typeID];
        delete tokenValues[_tokenID];

        _burn(_account, _tokenID, 1);
        _burn(_account, _typeID, 1);
    }

    /// METADATA

    /// @dev see { openzeppelin-contracts-upgradeable/token/ERC1155/extensions/ERC1155URIStorageUpgradeable.sol }
    /// @dev Always returns the URI for the basetype so that it's managed in one place.
    function uri(uint256 tokenID) public view override returns (string memory _uri) {
        _uri = Upgradeable1155.uri(getNonFungibleBaseType(tokenID));
    }

    /// TRANSFERS

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _id,
        uint256 _value,
        bytes memory _data
    ) public override {
        if (_to == address(0x0)) revert ToZeroAddress();
        if (_from != msg.sender) revert NotApprovedOrOwner(); //TODO Allowance approval
        if (getNonFungibleIndex(_id) == 0) revert NotAllowed();

        owners[_id] = _to;

        super.safeTransferFrom(_from, _to, _id, _value, _data);
    }

    // The following functions are overrides required by Solidity.
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override(Upgradeable1155) {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    function _afterTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        super._afterTokenTransfer(operator, from, to, ids, amounts, data);
    }

    function _authorizeUpgrade(address newImplementation) internal virtual override onlyOwner {
        // solhint-disable-previous-line no-empty-blocks
    }

    /**
     * @dev calculate the sum of the elements of an array
     */
    function _getSum(uint256[] memory array) internal pure returns (uint256 sum) {
        sum = 0;
        if (array.length == 0) {
            return sum;
        }

        for (uint256 i = 0; i < array.length; i++) {
            if (array[i] == 0) revert NotAllowed();
            sum += array[i];
        }

        return sum;
    }
}
