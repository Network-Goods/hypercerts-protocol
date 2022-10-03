// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "./interfaces/IERC3525MetadataUpgradeable.sol";
import "./interfaces/IERC3525Receiver.sol";
import "./interfaces/IERC3525SlotEnumerableUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";

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

abstract contract ERC3525Upgradeable is
    Initializable,
    ERC721EnumerableUpgradeable,
    ERC721BurnableUpgradeable,
    IERC3525MetadataUpgradeable,
    IERC3525SlotEnumerableUpgradeable
{
    using AddressUpgradeable for address;
    using StringsUpgradeable for uint256;

    struct ApproveData {
        address[] approvals;
        mapping(address => uint256) allowances;
    }

    /// @dev tokenId => values
    mapping(uint256 => uint256) internal _values;

    /// @dev tokenId => operator => units
    mapping(uint256 => ApproveData) private _approvedValues;

    /// @dev tokenId => slot
    mapping(uint256 => uint256) internal _slots;
    uint256[] internal _slotArray;

    /// @dev slot => tokenId[]
    mapping(uint256 => uint256[]) internal _tokensBySlot;

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721EnumerableUpgradeable, ERC721Upgradeable, IERC165Upgradeable)
        returns (bool)
    {
        return
            interfaceId == type(IERC3525MetadataUpgradeable).interfaceId ||
            interfaceId == type(IERC3525SlotEnumerableUpgradeable).interfaceId ||
            interfaceId == type(IERC3525Upgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function balanceOf(uint256 tokenId_) public view virtual override returns (uint256) {
        if (!_exists(tokenId_)) {
            revert NonExistentToken(tokenId_);
        }
        return _values[tokenId_];
    }

    function slotOf(uint256 tokenId_) public view virtual override returns (uint256) {
        if (!_exists(tokenId_)) {
            revert NonExistentToken(tokenId_);
        }
        return _slots[tokenId_];
    }

    function approve(
        uint256 tokenId_,
        address to_,
        uint256 value_
    ) external payable virtual override(IERC3525Upgradeable) {
        address owner = ERC721Upgradeable.ownerOf(tokenId_);
        if (to_ == owner) {
            revert InvalidApproval(tokenId_, msg.sender, to_);
        }

        if (ERC721Upgradeable._isApprovedOrOwner(_msgSender(), tokenId_)) {
            revert NotApprovedOrOwner();
        }

        _approveValue(tokenId_, to_, value_);
    }

    function allowance(uint256 tokenId_, address operator_) public view virtual override returns (uint256) {
        return _approvedValues[tokenId_].allowances[operator_];
    }

    /**
     * @notice Get the total amount of slots stored by the contract.
     * @return The total amount of slots
     */
    function slotCount() external view virtual override returns (uint256) {
        return _slotArray.length;
    }

    /**
     * @notice Get the slot at the specified index of all slots stored by the contract.
     * @param _index The index in the slot list
     * @return The slot at `index` of all slots.
     */
    function slotByIndex(uint256 _index) external view virtual override returns (uint256) {
        return _slotArray[_index];
    }

    /**
     * @notice Get the total amount of tokens with the same slot.
     * @param _slot The slot to query token supply for
     * @return The total amount of tokens with the specified `_slot`
     */
    function tokenSupplyInSlot(uint256 _slot) external view virtual override returns (uint256) {
        return _tokensBySlot[_slot].length;
    }

    /**
     * @notice Get the token at the specified index of all tokens with the same slot.
     * @param _slot The slot to query tokens with
     * @param _index The index in the token list of the slot
     * @return The token ID at `_index` of all tokens with `_slot`
     */
    function tokenInSlotByIndex(uint256 _slot, uint256 _index) external view virtual override returns (uint256) {
        return _tokensBySlot[_slot][_index];
    }

    function tokenFractions(uint256 _slot) internal view virtual returns (uint256[] memory) {
        uint256 tokenSupply = _tokensBySlot[_slot].length;
        uint256[] memory fractions = new uint256[](tokenSupply);
        for (uint256 i = 0; i < 25 && i < tokenSupply; i++) {
            fractions[i] = balanceOf(_tokensBySlot[_slot][i]);
        }
        return fractions;
    }

    function transferFrom(
        uint256 fromTokenId_,
        address to_,
        uint256 value_
    ) public payable virtual override returns (uint256 newTokenId) {
        _spendAllowance(_msgSender(), fromTokenId_, value_);

        newTokenId = _getNewTokenId(fromTokenId_);
        _mint(to_, newTokenId, _slots[fromTokenId_]);
        _transfer(fromTokenId_, newTokenId, value_);
    }

    function transferFrom(
        uint256 fromTokenId_,
        uint256 toTokenId_,
        uint256 value_
    ) public payable virtual override {
        _spendAllowance(_msgSender(), fromTokenId_, value_);

        _transfer(fromTokenId_, toTokenId_, value_);
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

    function _mint(
        address to_,
        uint256 tokenId_,
        uint256 slot_
    ) private {
        ERC721Upgradeable._mint(to_, tokenId_);
        _slots[tokenId_] = slot_;
        if (_tokensBySlot[slot_].length == 0) {
            _slotArray.push(slot_);
        }
        _tokensBySlot[slot_].push(tokenId_);
        emit SlotChanged(tokenId_, 0, slot_);
    }

    function _mintValue(
        address to_,
        uint256 tokenId_,
        uint256 slot_,
        uint256 value_
    ) internal virtual {
        if (to_ == address(0)) {
            revert ToZeroAddress();
        }
        if (tokenId_ == 0) {
            revert InvalidID(tokenId_);
        }
        if (_exists(tokenId_)) {
            revert AlreadyMinted(tokenId_);
        }

        _mint(to_, tokenId_, slot_);

        _beforeValueTransfer(address(0), to_, 0, tokenId_, slot_, value_);
        _values[tokenId_] = value_;
        _afterValueTransfer(address(0), to_, 0, tokenId_, slot_, value_);

        emit TransferValue(0, tokenId_, value_);
    }

    function _burn(uint256 tokenId_) internal virtual override(ERC721Upgradeable) {
        address owner = ERC721Upgradeable.ownerOf(tokenId_);
        uint256 slot = _slots[tokenId_];
        uint256 value = _values[tokenId_];

        ERC721Upgradeable._burn(tokenId_);

        _beforeValueTransfer(owner, address(0), tokenId_, 0, slot, value);
        delete _slots[tokenId_];
        delete _values[tokenId_];
        _afterValueTransfer(owner, address(0), tokenId_, 0, slot, value);

        emit TransferValue(tokenId_, 0, value);
        emit SlotChanged(tokenId_, slot, 0);
    }

    function _transfer(
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

        if (value_ >= _values[fromTokenId_]) {
            revert InsufficientBalance(value_, _values[fromTokenId_]);
        }

        if (_slots[fromTokenId_] != _slots[toTokenId_]) {
            revert SlotsMismatch(fromTokenId_, toTokenId_);
        }

        address from = ERC721Upgradeable.ownerOf(fromTokenId_);
        address to = ERC721Upgradeable.ownerOf(toTokenId_);
        _beforeValueTransfer(from, to, fromTokenId_, toTokenId_, _slots[fromTokenId_], value_);

        _values[fromTokenId_] -= value_;
        _values[toTokenId_] += value_;

        _afterValueTransfer(from, to, fromTokenId_, toTokenId_, _slots[fromTokenId_], value_);

        emit TransferValue(fromTokenId_, toTokenId_, value_);
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

    function _approveValue(
        uint256 tokenId_,
        address to_,
        uint256 value_
    ) internal virtual {
        ApproveData storage approveData = _approvedValues[tokenId_];
        approveData.approvals.push(to_);
        approveData.allowances[to_] = value_;

        emit ApprovalValue(tokenId_, to_, value_);
    }

    function _getNewTokenId(
        uint256 /*fromTokenId_*/
    ) internal virtual returns (uint256) {
        return ERC721EnumerableUpgradeable.totalSupply() + 1;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721EnumerableUpgradeable, ERC721Upgradeable) {
        super._beforeTokenTransfer(from, to, tokenId);
        // clear approve data
        uint256 length = _approvedValues[tokenId].approvals.length;
        for (uint256 i = 0; i < length; i++) {
            address approval = _approvedValues[tokenId].approvals[i];
            delete _approvedValues[tokenId].allowances[approval];
        }
        delete _approvedValues[tokenId].approvals;
    }

    function _checkOnERC3525Received(
        uint256 fromTokenId_,
        uint256 toTokenId_,
        uint256 value_,
        bytes memory data_
    ) private returns (bool) {
        address to = ERC721Upgradeable.ownerOf((toTokenId_));
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
}
