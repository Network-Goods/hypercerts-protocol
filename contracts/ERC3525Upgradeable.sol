// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "./interfaces/IERC3525MetadataUpgradeable.sol";
import "./interfaces/IERC3525Receiver.sol";

import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721ReceiverUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/IERC721EnumerableUpgradeable.sol";

error NonExistentToken(uint256 tokenId);
error NonExistentSlot(uint256 slotId);
error InsufficientBalance(uint256 transferAmount, uint256 balance);
error InsufficientAllowance(uint256 transferAmount, uint256 allowance);
error ToZeroAddress();
error InvalidID(uint256 tokenId);
error AlreadyMinted(uint256 tokenId);
error SlotsMismatch(uint256 fromTokenId, uint256 toTokenId);
error InvalidApproval(uint256 tokenId, address from, address to);
error NotApprovedOrOwner();
error NotERC3525Receiver(address receiver);

abstract contract ERC3525Upgradeable is
    Initializable,
    ERC165Upgradeable,
    IERC721EnumerableUpgradeable,
    IERC3525MetadataUpgradeable
{
    using AddressUpgradeable for address;
    using StringsUpgradeable for uint256;

    struct TokenData {
        uint256 id;
        uint256 slot;
        uint256 balance;
        address owner;
        address approved;
        address[] valueApprovals;
    }

    // struct ApproveData {
    //     address[] approvals;
    //     mapping(address => uint256) allowances;
    // }

    struct AddressData {
        uint256[] ownedTokens;
        mapping(uint256 => uint256) ownedTokensIndex;
        mapping(address => bool) approvals;
    }

    string private _name;
    string private _symbol;

    /// @dev tokenId => operator => units
    mapping(uint256 => mapping(address => uint256)) private _approvedValues;
    TokenData[] private _allTokens;

    //key: id
    mapping(uint256 => uint256) private _allTokensIndex;
    mapping(address => AddressData) private _addressData;

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC165Upgradeable, IERC165Upgradeable)
        returns (bool)
    {
        return
            interfaceId == type(IERC3525Upgradeable).interfaceId ||
            interfaceId == type(IERC721Upgradeable).interfaceId ||
            interfaceId == type(IERC3525MetadataUpgradeable).interfaceId ||
            interfaceId == type(IERC721EnumerableUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /*******************
     * VIEWS
     ******************/

    /**
     * @dev Returns the token collection name.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function balanceOf(uint256 tokenId_) public view virtual override returns (uint256) {
        if (!_exists(tokenId_)) {
            revert NonExistentToken(tokenId_);
        }
        return _allTokens[_allTokensIndex[tokenId_]].balance;
    }

    function balanceOf(address owner_) public view virtual override returns (uint256 balance) {
        if (owner_ == address(0)) {
            revert ToZeroAddress();
        }
        return _addressData[owner_].ownedTokens.length;
    }

    // ERC721 Compatible
    function ownerOf(uint256 tokenId_) public view virtual override returns (address owner_) {
        if (!_exists(tokenId_)) {
            revert NonExistentToken(tokenId_);
        }
        owner_ = _allTokens[_allTokensIndex[tokenId_]].owner;
        if (owner_ == address(0)) {
            revert NonExistentToken(tokenId_);
        }
    }

    function slotOf(uint256 tokenId_) public view virtual override returns (uint256) {
        if (!_exists(tokenId_)) {
            revert NonExistentToken(tokenId_);
        }
        return _allTokens[_allTokensIndex[tokenId_]].slot;
    }

    function allowance(uint256 tokenId_, address operator_) public view virtual override returns (uint256) {
        return _approvedValues[tokenId_][operator_];
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    function tokenByIndex(uint256 index_) public view virtual override returns (uint256) {
        if (index_ >= totalSupply()) {
            revert InvalidID(index_);
        }
        return _allTokens[index_].id;
    }

    function tokenOfOwnerByIndex(address owner_, uint256 index_) public view virtual override returns (uint256) {
        if (index_ >= balanceOf(owner_)) {
            revert InvalidID(index_);
        }
        return _addressData[owner_].ownedTokens[index_];
    }

    function _isApprovedOrOwner(address operator_, uint256 tokenId_) internal view virtual returns (bool) {
        if (!_exists(tokenId_)) {
            revert NonExistentToken(tokenId_);
        }
        address owner = ownerOf(tokenId_);
        return (operator_ == owner || isApprovedForAll(owner, operator_) || getApproved(tokenId_) == operator_);
    }

    function _exists(uint256 tokenId_) internal view virtual returns (bool) {
        return _allTokens.length != 0 && _allTokens[_allTokensIndex[tokenId_]].id == tokenId_;
    }

    /*******************
     * APPROVALS
     ******************/

    function approve(
        uint256 tokenId_,
        address to_,
        uint256 value_
    ) external payable virtual override(IERC3525Upgradeable) {
        address owner = ownerOf(tokenId_);
        if (to_ == owner) {
            revert InvalidApproval(tokenId_, to_, owner);
        }

        if (!_isApprovedOrOwner(_msgSender(), tokenId_)) {
            revert NotApprovedOrOwner();
        }

        _approveValue(tokenId_, to_, value_);
    }

    function approve(address to_, uint256 tokenId_) public virtual override {
        address owner = ownerOf(tokenId_);
        if (to_ == owner) {
            revert InvalidApproval(tokenId_, msg.sender, to_);
        }
        if (_msgSender() != owner && !isApprovedForAll(owner, _msgSender())) {
            revert NotApprovedOrOwner();
        }

        _approve(to_, tokenId_);
    }

    function getApproved(uint256 tokenId_) public view virtual override returns (address) {
        if (!_exists(tokenId_)) {
            revert NonExistentToken(tokenId_);
        }

        return _allTokens[_allTokensIndex[tokenId_]].approved;
    }

    function setApprovalForAll(address operator_, bool approved_) public virtual override {
        _setApprovalForAll(_msgSender(), operator_, approved_);
    }

    function isApprovedForAll(address owner_, address operator_) public view virtual override returns (bool) {
        return _addressData[owner_].approvals[operator_];
    }

    /*******************
     * TRANSFERS
     ******************/

    function transferFrom(
        uint256 fromTokenId_,
        address to_,
        uint256 value_
    ) public payable virtual override returns (uint256) {
        _spendAllowance(_msgSender(), fromTokenId_, value_);

        uint256 newTokenId = _createDerivedTokenId(fromTokenId_);
        _mint(to_, newTokenId, ERC3525Upgradeable.slotOf(fromTokenId_));
        _transferValue(fromTokenId_, newTokenId, value_);

        return newTokenId;
    }

    function transferFrom(
        uint256 fromTokenId_,
        uint256 toTokenId_,
        uint256 value_
    ) public payable virtual override {
        _spendAllowance(_msgSender(), fromTokenId_, value_);

        _transferValue(fromTokenId_, toTokenId_, value_);
    }

    function transferFrom(
        address from_,
        address to_,
        uint256 tokenId_
    ) public virtual override {
        if (!_isApprovedOrOwner(_msgSender(), tokenId_)) {
            revert NotApprovedOrOwner();
        }

        _transferTokenId(from_, to_, tokenId_);
    }

    function safeTransferFrom(
        address from_,
        address to_,
        uint256 tokenId_,
        bytes memory data_
    ) public virtual override {
        if (!_isApprovedOrOwner(_msgSender(), tokenId_)) {
            revert NotApprovedOrOwner();
        }
        _safeTransferTokenId(from_, to_, tokenId_, data_);
    }

    function safeTransferFrom(
        address from_,
        address to_,
        uint256 tokenId_
    ) public virtual override {
        safeTransferFrom(from_, to_, tokenId_, "");
    }

    function contractURI() public view virtual override returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "data:application/json;{",
                    '"name":',
                    name(),
                    ","
                    '"symbol":',
                    symbol(),
                    "}"
                )
            );
    }

    /*******************
     * INTERNAL
     ******************/

    /*******************
     * MINT AND BURN
     ******************/

    function _mint(
        address to_,
        uint256 tokenId_,
        uint256 slot_
    ) internal {
        TokenData memory tokenData = TokenData({
            id: tokenId_,
            slot: slot_,
            balance: 0,
            owner: to_,
            approved: address(0),
            valueApprovals: new address[](0)
        });

        _addTokenToAllTokensEnumeration(tokenData);
        _addTokenToOwnerEnumeration(to_, tokenId_);

        emit Transfer(address(0), to_, tokenId_);
        emit SlotChanged(tokenId_, 0, slot_);
    }

    function _mintValue(
        address to_,
        uint256 slot_,
        uint256 value_
    ) internal virtual returns (uint256 tokenId) {
        tokenId = _createOriginalTokenId();

        if (to_ == address(0)) {
            revert ToZeroAddress();
        }
        if (tokenId == 0) {
            revert InvalidID(tokenId);
        }
        if (_exists(tokenId)) {
            revert AlreadyMinted(tokenId);
        }

        _beforeValueTransfer(address(0), to_, 0, tokenId, slot_, value_);

        _mint(to_, tokenId, slot_);
        _allTokens[_allTokensIndex[tokenId]].balance = value_;

        emit TransferValue(0, tokenId, value_);

        _afterValueTransfer(address(0), to_, 0, tokenId, slot_, value_);

        return tokenId;
    }

    function _splitValue(uint256 fromToken_, uint256 value_) internal virtual returns (uint256 tokenId) {
        tokenId = _createOriginalTokenId();
        address to_ = _msgSender();
        address from_ = _msgSender();
        uint256 slot_ = slotOf(fromToken_);

        if (to_ == address(0)) {
            revert ToZeroAddress();
        }
        if (tokenId == 0) {
            revert InvalidID(tokenId);
        }
        if (_exists(tokenId)) {
            revert AlreadyMinted(tokenId);
        }

        _beforeValueTransfer(from_, to_, fromToken_, tokenId, slot_, value_);

        _mint(to_, tokenId, slot_);
        _allTokens[_allTokensIndex[tokenId]].balance = value_;
        _allTokens[_allTokensIndex[fromToken_]].balance -= value_;

        emit TransferValue(fromToken_, tokenId, value_);

        _afterValueTransfer(from_, to_, fromToken_, tokenId, slot_, value_);

        return tokenId;
    }

    function _burn(uint256 tokenId_) internal virtual {
        if (!_exists(tokenId_)) {
            revert NonExistentToken(tokenId_);
        }

        TokenData storage tokenData = _allTokens[_allTokensIndex[tokenId_]];
        address owner = tokenData.owner;

        if (msg.sender != owner) {
            revert NotApprovedOrOwner();
        }

        uint256 slot = tokenData.slot;
        uint256 value = tokenData.balance;

        _beforeValueTransfer(owner, address(0), tokenId_, 0, slot, value);

        _clearApprovedValues(tokenId_);
        _removeTokenFromAllTokensEnumeration(tokenId_);
        _removeTokenFromOwnerEnumeration(owner, tokenId_);

        emit TransferValue(tokenId_, 0, value);
        emit Transfer(owner, address(0), tokenId_);
        emit SlotChanged(tokenId_, slot, 0);

        _afterValueTransfer(owner, address(0), tokenId_, 0, slot, value);
    }

    /*******************
     * ALLOWANCES
     ******************/

    function _approve(address to_, uint256 tokenId_) internal virtual {
        _allTokens[_allTokensIndex[tokenId_]].approved = to_;
        emit Approval(ERC3525Upgradeable.ownerOf(tokenId_), to_, tokenId_);
    }

    function _approveValue(
        uint256 tokenId_,
        address to_,
        uint256 value_
    ) internal virtual {
        if (!_existApproveValue(to_, tokenId_)) {
            _allTokens[_allTokensIndex[tokenId_]].valueApprovals.push(to_);
        }
        _approvedValues[tokenId_][to_] = value_;

        emit ApprovalValue(tokenId_, to_, value_);
    }

    function _spendAllowance(
        address operator_,
        uint256 tokenId_,
        uint256 value_
    ) internal virtual {
        uint256 currentAllowance = ERC3525Upgradeable.allowance(tokenId_, operator_);
        if (!_isApprovedOrOwner(operator_, tokenId_) && currentAllowance != type(uint256).max) {
            if (currentAllowance < value_) {
                revert InsufficientAllowance(value_, currentAllowance);
            }
            _approveValue(tokenId_, operator_, currentAllowance - value_);
        }
    }

    function _clearApprovedValues(uint256 tokenId_) internal virtual {
        TokenData storage tokenData = _allTokens[_allTokensIndex[tokenId_]];
        uint256 length = tokenData.valueApprovals.length;
        for (uint256 i = 0; i < length; i++) {
            address approval = tokenData.valueApprovals[i];
            delete _approvedValues[tokenId_][approval];
        }
    }

    function _existApproveValue(address to_, uint256 tokenId_) internal view virtual returns (bool) {
        uint256 length = _allTokens[_allTokensIndex[tokenId_]].valueApprovals.length;
        for (uint256 i = 0; i < length; i++) {
            if (_allTokens[_allTokensIndex[tokenId_]].valueApprovals[i] == to_) {
                return true;
            }
        }
        return false;
    }

    function _setApprovalForAll(
        address owner_,
        address operator_,
        bool approved_
    ) internal virtual {
        if (owner_ == operator_) {
            revert InvalidApproval(0, owner_, operator_);
        }

        _addressData[owner_].approvals[operator_] = approved_;

        emit ApprovalForAll(owner_, operator_, approved_);
    }

    /*******************
     * TRANSFERS
     ******************/

    function _transferValue(
        uint256 fromTokenId_,
        uint256 toTokenId_,
        uint256 value_
    ) internal virtual {
        if (!_exists(fromTokenId_)) {
            revert NonExistentToken(fromTokenId_);
        }
        if (!_exists(toTokenId_)) {
            revert NonExistentToken(toTokenId_);
        }

        TokenData storage fromTokenData = _allTokens[_allTokensIndex[fromTokenId_]];
        TokenData storage toTokenData = _allTokens[_allTokensIndex[toTokenId_]];

        if (fromTokenData.balance < value_) {
            revert InsufficientBalance(value_, fromTokenData.balance);
        }
        if (fromTokenData.slot != toTokenData.slot) {
            revert SlotsMismatch(fromTokenData.slot, toTokenData.slot);
        }

        _beforeValueTransfer(
            fromTokenData.owner,
            toTokenData.owner,
            fromTokenId_,
            toTokenId_,
            fromTokenData.slot,
            value_
        );

        fromTokenData.balance -= value_;
        toTokenData.balance += value_;

        emit TransferValue(fromTokenId_, toTokenId_, value_);

        _afterValueTransfer(
            fromTokenData.owner,
            toTokenData.owner,
            fromTokenId_,
            toTokenId_,
            fromTokenData.slot,
            value_
        );

        if (!_checkOnERC3525Received(fromTokenId_, toTokenId_, value_, "")) {
            revert NotERC3525Receiver(ownerOf(toTokenId_));
        }
    }

    function _transferTokenId(
        address from_,
        address to_,
        uint256 tokenId_
    ) internal virtual {
        require(ownerOf(tokenId_) == from_, "ERC3525: transfer from incorrect owner");
        require(to_ != address(0), "ERC3525: transfer to the zero address");

        _beforeValueTransfer(from_, to_, tokenId_, tokenId_, slotOf(tokenId_), balanceOf(tokenId_));

        _approve(address(0), tokenId_);
        _clearApprovedValues(tokenId_);

        _removeTokenFromOwnerEnumeration(from_, tokenId_);
        _addTokenToOwnerEnumeration(to_, tokenId_);

        emit Transfer(from_, to_, tokenId_);

        _afterValueTransfer(from_, to_, tokenId_, tokenId_, slotOf(tokenId_), balanceOf(tokenId_));
    }

    function _safeTransferTokenId(
        address from_,
        address to_,
        uint256 tokenId_,
        bytes memory data_
    ) internal virtual {
        _transferTokenId(from_, to_, tokenId_);
        require(_checkOnERC721Received(from_, to_, tokenId_, data_), "ERC3525: transfer to non ERC721Receiver");
    }

    function _beforeValueTransfer(
        address from_,
        address to_,
        uint256 fromTokenId_,
        uint256 toTokenId_,
        uint256 slot_,
        uint256 value_ // solhint-disable-next-line no-empty-blocks
    ) internal virtual {
        // empty block
    }

    function _afterValueTransfer(
        address from_,
        address to_,
        uint256 fromTokenId_,
        uint256 toTokenId_,
        uint256 slot_,
        uint256 value_ // solhint-disable-next-line no-empty-blocks
    ) internal virtual {
        // empty block
    }

    function _checkOnERC3525Received(
        uint256 fromTokenId_,
        uint256 toTokenId_,
        uint256 value_,
        bytes memory data_
    ) private returns (bool) {
        address to = ownerOf((toTokenId_));
        if (to.isContract() && IERC165Upgradeable(to).supportsInterface(type(IERC3525Receiver).interfaceId)) {
            try IERC3525Receiver(to).onERC3525Received(_msgSender(), fromTokenId_, toTokenId_, value_, data_) returns (
                bytes4 retval
            ) {
                return retval == IERC3525Receiver.onERC3525Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC3525: transfer to non ERC3525Receiver implementer");
                } else {
                    // solhint-disable-next-line
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function _checkOnERC721Received(
        address from_,
        address to_,
        uint256 tokenId_,
        bytes memory data_
    ) private returns (bool) {
        if (
            to_.isContract() && IERC165Upgradeable(to_).supportsInterface(type(IERC721ReceiverUpgradeable).interfaceId)
        ) {
            try IERC721ReceiverUpgradeable(to_).onERC721Received(_msgSender(), from_, tokenId_, data_) returns (
                bytes4 retval
            ) {
                return retval == IERC721ReceiverUpgradeable.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver");
                } else {
                    // solhint-disable-next-line
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /*******************
     * TOKEN IDs
     ******************/

    function _createOriginalTokenId() internal virtual returns (uint256) {
        return _createDefaultTokenId();
    }

    function _createDerivedTokenId(uint256 fromTokenId_) internal virtual returns (uint256) {
        fromTokenId_;
        return _createDefaultTokenId();
    }

    function _createDefaultTokenId() private view returns (uint256) {
        return totalSupply() + 1;
    }

    /*******************
     * ENUMERATIONS
     ******************/

    function _addTokenToOwnerEnumeration(address to_, uint256 tokenId_) private {
        _allTokens[_allTokensIndex[tokenId_]].owner = to_;

        _addressData[to_].ownedTokensIndex[tokenId_] = _addressData[to_].ownedTokens.length;
        _addressData[to_].ownedTokens.push(tokenId_);
    }

    function _removeTokenFromOwnerEnumeration(address from_, uint256 tokenId_) private {
        _allTokens[_allTokensIndex[tokenId_]].owner = address(0);

        AddressData storage ownerData = _addressData[from_];
        uint256 lastTokenIndex = ownerData.ownedTokens.length - 1;
        uint256 lastTokenId = ownerData.ownedTokens[lastTokenIndex];
        uint256 tokenIndex = ownerData.ownedTokensIndex[tokenId_];

        ownerData.ownedTokens[tokenIndex] = lastTokenId;
        ownerData.ownedTokensIndex[lastTokenId] = tokenIndex;

        delete ownerData.ownedTokensIndex[tokenId_];
        ownerData.ownedTokens.pop();
    }

    function _addTokenToAllTokensEnumeration(TokenData memory tokenData_) private {
        _allTokensIndex[tokenData_.id] = _allTokens.length;
        _allTokens.push(tokenData_);
    }

    function _removeTokenFromAllTokensEnumeration(uint256 tokenId_) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId_];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        TokenData memory lastTokenData = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenData; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenData.id] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId_];
        _allTokens.pop();
    }

    function _msgSender() internal view virtual returns (address sender) {
        return msg.sender;
    }
}
