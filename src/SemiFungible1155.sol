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
error MaxValue();

/// @title Contract for minting semi-fungible EIP1155 tokens
/// @author bitbeckers
/// @notice Extends { Upgradeable1155 } token with semi-fungible properties and the concept of `units`
/// @dev Adds split bit strategy as described in [EIP-1155](https://eips.ethereum.org/EIPS/eip-1155#non-fungible-tokens)
contract SemiFungible1155 is Upgradeable1155 {
    /// @dev Counter used to generate next typeID.
    uint256 internal typeCounter;

    /// @dev Bitmask used to expose only upper 128 bits of uint256
    uint256 internal constant TYPE_MASK = uint256(uint128(int128(~0))) << 128;

    /// @dev Bitmask used to expose only lower 128 bits of uint256
    uint256 internal constant NF_INDEX_MASK = uint128(int128(~0));

    /// @dev Mapping of `tokenID` to address of `owner`
    mapping(uint256 => address) internal owners;

    /// @dev Mapping of `tokenID` to address of `creator`
    mapping(uint256 => address) internal creators; //TODO extend with admin contracts

    /// @dev Used to determine amount of `units` stored in token at `tokenID`
    mapping(uint256 => uint256) internal tokenValues;

    /// @dev Used to find highest index of token belonging to token at `typeID`
    mapping(uint256 => uint256) internal maxIndex;

    /// @dev Emitted on transfer of `value` between `fromTokenID` to `toTokenID` of the same `claimID`
    event ValueTransfer(uint256 claimID, uint256 fromTokenID, uint256 toTokenID, uint256 value);

    /// @dev Emitted on transfer of `values` between `fromTokenIDs` to `toTokenIDs` of `claimIDs`
    event BatchValueTransfer(uint256[] claimIDs, uint256[] fromTokenIDs, uint256[] toTokenIDs, uint256[] values);

    /// @dev Init method. Underlying { Upgradeable1155 } is `Initializable`
    // solhint-disable-next-line func-name-mixedcase
    function __SemiFungible1155_init() public virtual onlyInitializing {
        __Upgradeable1155_init();
    }

    /// @dev Get index of fractional token at `_id` by returning lower 128 bit values
    /// @dev Returns 0 if `_id` is a baseType
    function getItemIndex(uint256 tokenID) internal pure returns (uint256) {
        return tokenID & NF_INDEX_MASK;
    }

    /// @dev Get base type ID for token at `_id` by returning upper 128 bit values
    function getBaseType(uint256 tokenID) internal pure returns (uint256) {
        return tokenID & TYPE_MASK;
    }

    /// @dev Identify that token at `_id` is base type.
    /// @dev Upper 128 bits identify base type ID, lower bits should be 0
    function isBaseType(uint256 tokenID) internal pure returns (bool) {
        return (tokenID & TYPE_MASK == tokenID) && (tokenID & NF_INDEX_MASK == 0);
    }

    /// @dev Identify that token at `_id` is fraction of a claim.
    /// @dev Upper 128 bits identify base type ID, lower bits should be > 0
    function isTypedItem(uint256 tokenID) internal pure returns (bool) {
        return (tokenID & TYPE_MASK > 0) && (tokenID & NF_INDEX_MASK > 0);
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
        if (getItemIndex(tokenID) != 0 && ownerOf(tokenID) == account) {
            units = tokenValues[tokenID];
        }

        return units;
    }

    /// MUTATE

    /// @dev create token type ID based of token counter
    // TODO should creator be msg.sender or submit account?
    function _createTokenType(uint256 units, string memory _uri) internal returns (uint256 typeID) {
        _notMaxType(typeCounter);
        typeID = (++typeCounter << 128);

        owners[typeID] = _msgSender();
        creators[typeID] = _msgSender();
        tokenValues[typeID] = units;

        _mint(_msgSender(), typeID, 1, "");
        _setURI(typeID, _uri);
    }

    /// @dev Mint a new token type and the initial value
    function _mintValue(address _account, uint256 _value, string memory _uri) internal returns (uint256 typeID) {
        if (_value == 0) {
            revert NotAllowed();
        }
        typeID = _createTokenType(_value, _uri);

        uint256 itemIndex = ++maxIndex[typeID];
        uint256 tokenID = typeID + itemIndex; //1 based indexing, 0 holds type data

        owners[tokenID] = _account;
        tokenValues[tokenID] = _value;

        _mint(_account, tokenID, 1, "");
        emit ValueTransfer(typeID, 0, tokenID, _value);
    }

    /// @dev Mint a new token type and the initial fractions
    function _mintValue(
        address _account,
        uint256[] memory _values,
        string memory _uri
    ) internal returns (uint256 typeID) {
        if (_values.length > 253) {
            //TODO determine array limits (use testing)
            revert ArraySize();
        }

        uint256 totalValue = _getSum(_values);

        typeID = _mintValue(_account, totalValue, _uri);

        _splitValue(_account, typeID + maxIndex[typeID], _values);
    }

    /// @dev Mint a new token for an existing type
    function _mintClaim(uint256 _typeID, uint256 _units) internal returns (uint256 tokenID) {
        _notMaxItem(maxIndex[_typeID]);
        tokenID = _typeID + ++maxIndex[_typeID]; //1 based indexing, 0 holds type data

        address _account = _msgSender();
        owners[tokenID] = _account;
        tokenValues[tokenID] = _units;

        _mint(_account, tokenID, 1, "");
        emit ValueTransfer(_typeID, 0, tokenID, _units);
    }

    /// @dev Mint new tokens for existing types
    /// @notice Enables batch claiming from multiple allowlists
    function _batchMintClaims(
        uint256[] calldata _typeIDs,
        uint256[] calldata _units
    ) internal returns (uint256 tokenID) {
        address _account = _msgSender();

        uint256 len = _typeIDs.length;
        uint256[] memory tokenIDs = new uint256[](len);
        uint256[] memory amounts = new uint256[](len);

        for (uint256 i = 0; i < len; i++) {
            uint256 _typeID = _typeIDs[i];

            _notMaxItem(maxIndex[_typeID]);
            tokenID = _typeID + ++maxIndex[_typeID]; //1 based indexing, 0 holds type data

            owners[tokenID] = _account;
            tokenValues[tokenID] = _units[i];
            tokenIDs[i] = tokenID;
            amounts[i] = 1;
        }

        _mintBatch(_account, tokenIDs, amounts, "");

        //TODO something cleaner than instantiating zeroes array
        uint256[] memory zeroes = new uint256[](len);
        emit BatchValueTransfer(_typeIDs, zeroes, tokenIDs, _units);
    }

    /// @dev Split the units of `_tokenID` owned by `account` across `_values`
    /// @dev `_values` must sum to total `units` held at `_tokenID`
    function _splitValue(address _account, uint256 _tokenID, uint256[] memory _values) internal {
        if (_values.length > 253 || _values.length < 2) {
            revert ArraySize();
        }

        if (isBaseType(_tokenID)) {
            revert NotAllowed();
        }

        uint256 _typeID = getBaseType(_tokenID);
        uint256 currentID = _tokenID;

        uint256 len = _values.length;
        uint256 value = tokenValues[_tokenID];

        _notMaxItem(currentID + len);

        // starts with 1 because 0 remains the same
        for (uint256 i = 1; i < len; i++) {
            uint256 tokenID = currentID + i;

            owners[tokenID] = _account;
            tokenValues[tokenID] = _values[i];
            value -= _values[i];
            _notMaxItem(tokenID);
            _mint(_account, tokenID, 1, ""); //TODO batchmint?
            emit ValueTransfer(_typeID, currentID, tokenID, _values[i]);
        }

        tokenValues[currentID] = value;

        maxIndex[_typeID] += len;
    }

    /// @dev Merge the units of `_fractionIDs`.
    /// @dev Base type of `_fractionIDs` must be identical for all tokens.
    // TODO optimise merge, possibly batch burn and mint 1 new?
    // TODO emit events
    function _mergeValue(uint256[] memory _fractionIDs) internal {
        if (_fractionIDs.length > 253 || _fractionIDs.length < 2) {
            revert ArraySize();
        }
        uint256 len = _fractionIDs.length;

        uint256 target = _fractionIDs[len - 1];
        uint256 _typeID = getBaseType(target);

        uint256 _totalValue = 0;
        uint256[] memory _valuesToBurn = new uint256[](len - 1);
        uint256[] memory _idsToBurn = new uint256[](len - 1);

        address _account = _msgSender();
        for (uint256 i = 0; i < len; i++) {
            if (getBaseType(_fractionIDs[i]) != _typeID) revert TypeMismatch();
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
        uint256 _typeID = getBaseType(_tokenID);
        if (isBaseType(_tokenID)) revert NotAllowed();
        if (tokenValues[_tokenID] != tokenValues[_typeID]) revert FractionalBurn();

        delete owners[_typeID];
        delete owners[_tokenID];
        delete tokenValues[_typeID];
        delete tokenValues[_tokenID];

        _burn(_account, _tokenID, 1);
        _burn(_account, _typeID, 1);
    }

    /// TRANSFERS

    // The following functions are overrides required by Solidity.
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        for (uint256 i = 0; i < ids.length; ++i) {
            if (isBaseType(ids[i]) && from != address(0)) revert NotAllowed();
            owners[ids[i]] = to;
        }

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

    /// METADATA

    /// @dev see { openzeppelin-contracts-upgradeable/token/ERC1155/extensions/ERC1155URIStorageUpgradeable.sol }
    /// @dev Always returns the URI for the basetype so that it's managed in one place.
    function uri(uint256 tokenID) public view virtual override returns (string memory _uri) {
        _uri = Upgradeable1155.uri(getBaseType(tokenID));
    }

    /// UTILS

    /**
     * @dev Check is value is below max item index
     */
    function _notMaxItem(uint256 tokenID) internal pure {
        uint128 _count = uint128(tokenID);
        ++_count;
    }

    /**
     * @dev Check is value is below max type index
     */
    function _notMaxType(uint256 tokenID) internal pure {
        uint128 _count = uint128(tokenID >> 128);
        ++_count;
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
    }
}
