// SPDX-License-Identifier: MIT
// Used components of Enjin example implementation for mixed fungibility
// https://github.com/enjin/erc-1155/blob/master/contracts/ERC1155MixedFungibleMintable.sol
pragma solidity ^0.8.9;

import { Upgradeable1155 } from "./Upgradeable1155.sol";
import { IERC1155ReceiverUpgradeable } from "@oz-upgradeable/token/ERC1155/IERC1155ReceiverUpgradeable.sol";

// TODO shared error lib
error ArraySize();
error ToZeroAddress();
error NotApprovedOrOwner();
error NotAllowed();
error TypeMismatch();
error FractionalBurn();

contract SemiFungible1155 is Upgradeable1155 {
    uint256 public typeCounter;
    // Use a split bit implementation.
    // Store the type in the upper 128 bits..
    uint256 public constant TYPE_MASK = uint256(uint128(int128(~0))) << 128;

    // ..and the non-fungible index in the lower 128
    uint256 public constant NF_INDEX_MASK = uint128(int128(~0));

    // The top bit is a flag to tell if this is a NFI.
    uint256 public constant TYPE_NF_BIT = 1 << 255;

    mapping(uint256 => address) public owners;
    mapping(uint256 => address) public creators; //TODO extend with admin contracts

    mapping(uint256 => uint256) public tokenValues;
    mapping(uint256 => uint256) internal maxIndex;
    mapping(uint256 => mapping(address => uint256)) public tokenUserBalances;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    // solhint-disable-next-line func-name-mixedcase
    function __SemiFungible1155_init() public virtual initializer {
        __Upgradeable1155_init();
    }

    /// ENJIN EXAMPLE IMPLEMENTATION
    // Only to make code clearer. Should not be functions
    // TODO cleanup functions
    function isNonFungible(uint256 _id) internal pure returns (bool) {
        return _id & TYPE_NF_BIT == TYPE_NF_BIT;
    }

    function isFungible(uint256 _id) internal pure returns (bool) {
        return _id & TYPE_NF_BIT == 0;
    }

    function getNonFungibleIndex(uint256 _id) internal pure returns (uint256) {
        return _id & NF_INDEX_MASK;
    }

    function getNonFungibleBaseType(uint256 _id) internal pure returns (uint256) {
        return _id & TYPE_MASK;
    }

    function isNonFungibleBaseType(uint256 _id) internal pure returns (bool) {
        // A base type has the NF bit but does not have an index.
        return (_id & TYPE_NF_BIT == TYPE_NF_BIT) && (_id & NF_INDEX_MASK == 0);
    }

    function isNonFungibleItem(uint256 _id) internal pure returns (bool) {
        // A base type has the NF bit but does has an index.
        return (_id & TYPE_NF_BIT == TYPE_NF_BIT) && (_id & NF_INDEX_MASK != 0);
    }

    /// READ

    function balanceOf(address _owner, uint256 _tokenID) public view override returns (uint256 tokenUserBalance) {
        tokenUserBalance = tokenUserBalances[_tokenID][_owner];
    }

    function balanceOf(uint256 _tokenID) public view returns (uint256 tokenValue) {
        tokenValue = tokenValues[_tokenID];
    }

    function totalSupply(uint256 _typeID) external view returns (uint256 total) {
        total = tokenValues[_typeID];
    }

    /// MUTATE

    /// @dev create token type ID based of token counter
    // TODO should creator be msg.sender or inital account?
    function _createTokenType() internal returns (uint256 typeID) {
        typeID = (++typeCounter << 128); //TODO max value check?
        creators[typeID] = msg.sender;
    }

    /// @dev create token type ID based of token counter
    function _createTokenType(uint256 units, string memory uri) internal returns (uint256 typeID) {
        typeID = (++typeCounter << 128); //TODO max value check?
        _setURI(typeID, uri);

        creators[typeID] = msg.sender;
        tokenValues[typeID] = units;
    }

    /// @dev Mint a new token type and the initial value
    function _mintValue(address _account, uint256 _value, string memory uri) internal returns (uint256 typeID) {
        typeID = _createTokenType();
        maxIndex[typeID] += 1;
        uint256 tokenID = typeID + maxIndex[typeID]; //1 based indexing, 0 holds type data

        _mint(_account, tokenID, 1, "");
        _setURI(tokenID, uri);
        owners[tokenID] = _account;

        tokenValues[typeID] = _value; // total value at 0-index
        tokenValues[tokenID] = _value; //first fraction

        //TODO these balances might not be needed, maybe only total ownership of hypercert.
        tokenUserBalances[typeID][_account] = _value; // creator of fraction gets full value
        tokenUserBalances[tokenID][_account] = _value; // creator of fraction gets full value
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
        _mintValue(_account, totalValue, uri);

        typeID = typeCounter << 128; //TODO max value check

        splitValue(_account, typeID + maxIndex[typeID], _values);
    }

    /// @dev Mint a new token for an existing type
    function _mintClaim(uint256 _typeID, uint256 _units) internal returns (uint256 tokenID) {
        maxIndex[_typeID] += 1;
        tokenID = _typeID + maxIndex[_typeID]; //1 based indexing, 0 holds type data

        address _account = msg.sender;

        _mint(_account, tokenID, 1, "");
        owners[tokenID] = _account;

        //TODO these balances might not be needed, maybe only total ownership of hypercert.
        tokenUserBalances[_typeID][_account] += _units; // creator of fraction gets full value
        tokenUserBalances[tokenID][_account] = _units; // creator of fraction gets full value
    }

    function splitValue(address _account, uint256 _tokenID, uint256[] memory _values) public {
        if (_values.length > 253) {
            revert ArraySize();
        }

        if (getNonFungibleIndex(_tokenID) == 0) {
            revert NotAllowed();
        }

        uint256 _typeID = getNonFungibleBaseType(_tokenID);
        uint256 newFractionsStartID = _typeID + maxIndex[_typeID];

        uint256 len = _values.length;
        uint256 left = tokenValues[_tokenID];

        for (uint256 i = 1; i < len; i++) {
            uint256 tokenID = newFractionsStartID + i;

            _mint(_account, tokenID, 1, "");

            tokenValues[tokenID] = _values[i];
            tokenUserBalances[tokenID][_account] = _values[i];
            left -= _values[i];
        }

        tokenValues[_tokenID] = left;
        tokenUserBalances[_tokenID][_account] = left;

        maxIndex[_typeID] += len;
    }

    function mergeValue(uint256[] memory _fractionIDs) public {
        if (_fractionIDs.length > 253) {
            revert ArraySize();
        }
        uint256 len = _fractionIDs.length;

        uint256 target = _fractionIDs[len - 1];
        uint256 _typeID = getNonFungibleBaseType(target);

        for (uint256 i = 0; i < len; i++) {
            if (getNonFungibleBaseType(_fractionIDs[i]) != _typeID) revert TypeMismatch();
            uint256 _fractionID = _fractionIDs[i];
            if (_fractionID != target) {
                tokenValues[target] += tokenValues[_fractionID];
                delete tokenValues[_fractionID];
            }
        }
    }

    function burnValue(address _account, uint256 _tokenID) public {
        uint256 _typeID = getNonFungibleBaseType(_tokenID);
        if (getNonFungibleIndex(_tokenID) == 0) revert NotAllowed();
        if (tokenValues[_tokenID] != tokenValues[_typeID]) revert FractionalBurn();
        delete tokenValues[_typeID];
        delete tokenValues[_tokenID];
        delete tokenUserBalances[_typeID][_account]; //TODO delete all balances
        delete tokenUserBalances[_tokenID][_account]; //TODO delete all balances
    }

    /// Transfers
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _id,
        uint256 _value,
        bytes memory _data
    ) public override {
        if (_to == address(0x0)) revert ToZeroAddress();
        if (_from != msg.sender) revert NotApprovedOrOwner(); //TODO Allowance approval

        uint256 value = tokenValues[_id];

        if (isNonFungible(_id)) {
            if (owners[_id] != _from) revert NotApprovedOrOwner();
            owners[_id] = _to;
        } else {
            uint256 typeID = getNonFungibleBaseType(_id);

            tokenUserBalances[typeID][_from] -= value;
            tokenUserBalances[typeID][_to] += value;

            tokenUserBalances[_id][_from] -= value;
            tokenUserBalances[_id][_to] += value;
        }

        emit TransferSingle(msg.sender, _from, _to, _id, _value);

        // TODO added extra underscore to bypass non-virtual override conflict
        if (_isContract(_to)) {
            __doSafeTransferAcceptanceCheck(msg.sender, _from, _to, _id, _value, _data);
        }
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
        if (array.length == 0) {
            return 0;
        }
        sum = 0;
        for (uint256 i = 0; i < array.length; i++) sum += array[i];
    }

    function __doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {
        try IERC1155ReceiverUpgradeable(to).onERC1155Received(operator, from, id, amount, data) returns (
            bytes4 response
        ) {
            if (response != IERC1155ReceiverUpgradeable.onERC1155Received.selector) {
                revert("ERC1155: ERC1155Receiver rejected tokens");
            }
        } catch Error(string memory reason) {
            revert(reason);
        } catch {
            revert("ERC1155: transfer to non-ERC1155Receiver implementer");
        }
    }

    function _isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }
}
