# Solidity API

## NonExistentToken

```solidity
error NonExistentToken(uint256 tokenId)
```

## NonExistentSlot

```solidity
error NonExistentSlot(uint256 slotId)
```

## InsufficientBalance

```solidity
error InsufficientBalance(uint256 transferAmount, uint256 balance)
```

## InsufficientAllowance

```solidity
error InsufficientAllowance(uint256 transferAmount, uint256 allowance)
```

## ToZeroAddress

```solidity
error ToZeroAddress()
```

## InvalidID

```solidity
error InvalidID(uint256 tokenId)
```

## AlreadyMinted

```solidity
error AlreadyMinted(uint256 tokenId)
```

## SlotsMismatch

```solidity
error SlotsMismatch(uint256 fromTokenId, uint256 toTokenId)
```

## InvalidApproval

```solidity
error InvalidApproval(uint256 tokenId, address from, address to)
```

## NotApprovedOrOwner

```solidity
error NotApprovedOrOwner()
```

## ERC3525Upgradeable

### ApproveData

```solidity
struct ApproveData {
  address[] approvals;
  mapping(address => uint256) allowances;
}

```

### \_values

```solidity
mapping(uint256 => uint256) _values
```

_tokenId => values_

### \_approvedValues

```solidity
mapping(uint256 => struct ERC3525Upgradeable.ApproveData) _approvedValues
```

_tokenId => operator => units_

### \_slots

```solidity
mapping(uint256 => uint256) _slots
```

_tokenId => slot_

### \_slotArray

```solidity
uint256[] _slotArray
```

### \_tokensBySlot

```solidity
mapping(uint256 => uint256[]) _tokensBySlot
```

_slot => tokenId[]_

### supportsInterface

```solidity
function supportsInterface(bytes4 interfaceId) public view virtual returns (bool)
```

### balanceOf

```solidity
function balanceOf(uint256 tokenId_) public view virtual returns (uint256)
```

### slotOf

```solidity
function slotOf(uint256 tokenId_) public view virtual returns (uint256)
```

### approve

```solidity
function approve(uint256 tokenId_, address to_, uint256 value_) external payable virtual
```

### allowance

```solidity
function allowance(uint256 tokenId_, address operator_) public view virtual returns (uint256)
```

### slotCount

```solidity
function slotCount() external view virtual returns (uint256)
```

Get the total amount of slots stored by the contract.

| Name | Type    | Description               |
| ---- | ------- | ------------------------- |
| [0]  | uint256 | The total amount of slots |

### slotByIndex

```solidity
function slotByIndex(uint256 _index) external view virtual returns (uint256)
```

Get the slot at the specified index of all slots stored by the contract.

| Name    | Type    | Description                |
| ------- | ------- | -------------------------- |
| \_index | uint256 | The index in the slot list |

| Name | Type    | Description                       |
| ---- | ------- | --------------------------------- |
| [0]  | uint256 | The slot at `index` of all slots. |

### tokenSupplyInSlot

```solidity
function tokenSupplyInSlot(uint256 _slot) external view virtual returns (uint256)
```

Get the total amount of tokens with the same slot.

| Name   | Type    | Description                        |
| ------ | ------- | ---------------------------------- |
| \_slot | uint256 | The slot to query token supply for |

| Name | Type    | Description                                           |
| ---- | ------- | ----------------------------------------------------- |
| [0]  | uint256 | The total amount of tokens with the specified `_slot` |

### tokenInSlotByIndex

```solidity
function tokenInSlotByIndex(uint256 _slot, uint256 _index) external view virtual returns (uint256)
```

Get the token at the specified index of all tokens with the same slot.

| Name    | Type    | Description                             |
| ------- | ------- | --------------------------------------- |
| \_slot  | uint256 | The slot to query tokens with           |
| \_index | uint256 | The index in the token list of the slot |

| Name | Type    | Description                                         |
| ---- | ------- | --------------------------------------------------- |
| [0]  | uint256 | The token ID at `_index` of all tokens with `_slot` |

### tokenFractions

```solidity
function tokenFractions(uint256 _slot) internal view virtual returns (uint256[])
```

### transferFrom

```solidity
function transferFrom(uint256 fromTokenId_, address to_, uint256 value_) public payable virtual returns (uint256 newTokenId)
```

### transferFrom

```solidity
function transferFrom(uint256 fromTokenId_, uint256 toTokenId_, uint256 value_) public payable virtual
```

### contractURI

```solidity
function contractURI() public view virtual returns (string)
```

Returns the Uniform Resource Identifier (URI) for the current ERC3525 contract.

_This function SHOULD return the URI for this contract in JSON format, starting with
header `data:application/json;`.
See https://eips.ethereum.org/EIPS/eip-3525 for the JSON schema for contract URI._

| Name | Type   | Description                                            |
| ---- | ------ | ------------------------------------------------------ |
| [0]  | string | The JSON formatted URI of the current ERC3525 contract |

### \_mint

```solidity
function _mint(address to_, uint256 tokenId_, uint256 slot_) internal
```

### \_mintValue

```solidity
function _mintValue(address to_, uint256 tokenId_, uint256 slot_, uint256 value_) internal virtual
```

### \_burn

```solidity
function _burn(uint256 tokenId_) internal virtual
```

### \_transfer

```solidity
function _transfer(uint256 fromTokenId_, uint256 toTokenId_, uint256 value_) internal virtual
```

### \_spendAllowance

```solidity
function _spendAllowance(address operator_, uint256 tokenId_, uint256 value_) internal virtual
```

### \_approveValue

```solidity
function _approveValue(uint256 tokenId_, address to_, uint256 value_) internal virtual
```

### \_getNewTokenId

```solidity
function _getNewTokenId(uint256) internal virtual returns (uint256)
```

### \_beforeTokenTransfer

```solidity
function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual
```

### \_checkOnERC3525Received

```solidity
function _checkOnERC3525Received(uint256 fromTokenId_, uint256 toTokenId_, uint256 value_, bytes data_) private returns (bool)
```

### \_beforeValueTransfer

```solidity
function _beforeValueTransfer(address from_, address to_, uint256 fromTokenId_, uint256 toTokenId_, uint256 slot_, uint256 value_) internal virtual
```

### \_afterValueTransfer

```solidity
function _afterValueTransfer(address from_, address to_, uint256 fromTokenId_, uint256 toTokenId_, uint256 slot_, uint256 value_) internal virtual
```

## EmptyInput

```solidity
error EmptyInput()
```

## DuplicateScope

```solidity
error DuplicateScope()
```

## InvalidScope

```solidity
error InvalidScope()
```

## InvalidTimeframe

```solidity
error InvalidTimeframe(uint64 from, uint64 to)
```

## ConflictingClaim

```solidity
error ConflictingClaim()
```

## HypercertMinter

Contains functions and events to initialize and issue a hypercertificate

### NAME

```solidity
string NAME
```

Contract name

### SYMBOL

```solidity
string SYMBOL
```

Token symbol

### DECIMALS

```solidity
uint8 DECIMALS
```

Token value decimals

### UPGRADER_ROLE

```solidity
bytes32 UPGRADER_ROLE
```

User role required in order to upgrade the contract

### \_version

```solidity
uint16 _version
```

Current version of the contract

### \_metadata

```solidity
address _metadata
```

Hypercert metadata contract

### workScopes

```solidity
mapping(bytes32 => string) workScopes
```

Mapping of id's to work-scopes

### impactScopes

```solidity
mapping(bytes32 => string) impactScopes
```

Mapping of id's to impact-scopes

### rights

```solidity
mapping(bytes32 => string) rights
```

Mapping of id's to rights

### \_contributorImpacts

```solidity
mapping(address => mapping(bytes32 => bool)) _contributorImpacts
```

### \_impactCerts

```solidity
mapping(uint256 => struct HypercertMinter.Claim) _impactCerts
```

### Claim

```solidity
struct Claim {
  bytes32 claimHash;
  uint64[2] workTimeframe;
  uint64[2] impactTimeframe;
  bytes32[] workScopes;
  bytes32[] impactScopes;
  bytes32[] rights;
  address[] contributors;
  uint256 totalUnits;
  uint16 version;
  bool exists;
  string name;
  string description;
  string uri;
}

```

### ImpactClaimed

```solidity
event ImpactClaimed(uint256 id, address minter, uint8[] fractions)
```

Emitted when an impact is claimed.

| Name      | Type    | Description                                 |
| --------- | ------- | ------------------------------------------- |
| id        | uint256 | Id of the claimed impact.                   |
| minter    | address | Address of cert minter.                     |
| fractions | uint8[] | Units of tokens issued under the hypercert. |

### ImpactScopeAdded

```solidity
event ImpactScopeAdded(bytes32 id, string text)
```

Emitted when a new impact scope is added.

| Name | Type    | Description                          |
| ---- | ------- | ------------------------------------ |
| id   | bytes32 | Id of the impact scope.              |
| text | string  | Short text code of the impact scope. |

### RightAdded

```solidity
event RightAdded(bytes32 id, string text)
```

Emitted when a new right is added.

| Name | Type    | Description                   |
| ---- | ------- | ----------------------------- |
| id   | bytes32 | Id of the right.              |
| text | string  | Short text code of the right. |

### WorkScopeAdded

```solidity
event WorkScopeAdded(bytes32 id, string text)
```

Emitted when a new work scope is added.

| Name | Type    | Description                        |
| ---- | ------- | ---------------------------------- |
| id   | bytes32 | Id of the work scope.              |
| text | string  | Short text code of the work scope. |

### constructor

```solidity
constructor() public
```

Contract constructor logic

### initialize

```solidity
function initialize(address metadataAddress) public
```

Contract initialization logic

### addImpactScope

```solidity
function addImpactScope(string text) public returns (bytes32 id)
```

Adds a new impact scope

| Name | Type   | Description                        |
| ---- | ------ | ---------------------------------- |
| text | string | Text representing the impact scope |

| Name | Type    | Description            |
| ---- | ------- | ---------------------- |
| id   | bytes32 | Id of the impact scope |

### addRight

```solidity
function addRight(string text) public returns (bytes32 id)
```

Adds a new right

| Name | Type   | Description                 |
| ---- | ------ | --------------------------- |
| text | string | Text representing the right |

| Name | Type    | Description     |
| ---- | ------- | --------------- |
| id   | bytes32 | Id of the right |

### addWorkScope

```solidity
function addWorkScope(string text) public returns (bytes32 id)
```

Adds a new work scope

| Name | Type   | Description                      |
| ---- | ------ | -------------------------------- |
| text | string | Text representing the work scope |

| Name | Type    | Description          |
| ---- | ------- | -------------------- |
| id   | bytes32 | Id of the work scope |

### mint

```solidity
function mint(address account, bytes data) public virtual
```

Issues a new hypercertificate

| Name    | Type    | Description                                   |
| ------- | ------- | --------------------------------------------- |
| account | address | Account issuing the new hypercertificate      |
| data    | bytes   | Data representing the parameters of the claim |

### split

```solidity
function split(uint256 tokenId, uint8[] amounts) public
```

### merge

```solidity
function merge(uint256[] tokenIds) public
```

### getImpactCert

```solidity
function getImpactCert(uint256 claimID) public view returns (struct HypercertMinter.Claim)
```

Gets the impact claim with the specified id

| Name    | Type    | Description     |
| ------- | ------- | --------------- |
| claimID | uint256 | Id of the claim |

| Name | Type                         | Description                                        |
| ---- | ---------------------------- | -------------------------------------------------- |
| [0]  | struct HypercertMinter.Claim | The claim, if it doesn't exist with default values |

### version

```solidity
function version() public view virtual returns (uint256)
```

gets the current version of the contract

### updateVersion

```solidity
function updateVersion() external
```

Update the contract version number
Only allowed for member of UPGRADER_ROLE

### supportsInterface

```solidity
function supportsInterface(bytes4 interfaceId) public view returns (bool)
```

Returns a flag indicating if the contract supports the specified interface

| Name        | Type   | Description         |
| ----------- | ------ | ------------------- |
| interfaceId | bytes4 | Id of the interface |

| Name | Type | Description                         |
| ---- | ---- | ----------------------------------- |
| [0]  | bool | true, if the interface is supported |

### name

```solidity
function name() public pure returns (string)
```

### symbol

```solidity
function symbol() public pure returns (string)
```

### valueDecimals

```solidity
function valueDecimals() public view virtual returns (uint8)
```

Get the number of decimals the token uses for value - e.g. 6, means the user
representation of the value of a token can be calculated by dividing it by 1,000,000.
Considering the compatibility with third-party wallets, this function is defined as
`valueDecimals()` instead of `decimals()` to avoid conflict with EIP-20 tokens.

| Name | Type  | Description                      |
| ---- | ----- | -------------------------------- |
| [0]  | uint8 | The number of decimals for value |

### getHash

```solidity
function getHash(uint64[2] workTimeframe_, bytes32[] workScopes_, uint64[2] impactTimeframe_, bytes32[] impactScopes_) public pure virtual returns (bytes32)
```

### slotURI

```solidity
function slotURI(uint256 slotId_) external view returns (string)
```

### tokenURI

```solidity
function tokenURI(uint256 tokenId_) public view returns (string)
```

### \_authorizeUpgrade

```solidity
function _authorizeUpgrade(address) internal view
```

upgrade authorization logic

_adds onlyRole(UPGRADER_ROLE) requirement_

### \_authorizeAdd

```solidity
function _authorizeAdd(string text, mapping(bytes32 => string) map) internal view virtual returns (bytes32 id)
```

Pre-add validation checks

| Name | Type                               | Description                           |
| ---- | ---------------------------------- | ------------------------------------- |
| text | string                             | Text to be added                      |
| map  | mapping(bytes32 &#x3D;&gt; string) | Storage mapping that will be appended |

### \_authorizeMint

```solidity
function _authorizeMint(address account, struct HypercertMinter.Claim claim) internal view virtual
```

Pre-mint validation checks

| Name    | Type                         | Description                      |
| ------- | ---------------------------- | -------------------------------- |
| account | address                      | Destination address for the mint |
| claim   | struct HypercertMinter.Claim | Impact claim data                |

### \_parseData

```solidity
function _parseData(bytes data) internal pure virtual returns (struct HypercertMinter.Claim claim, uint8[])
```

Parse bytes to Claim and URI

_This function is overridable in order to support future schema changes_

| Name | Type  | Description                      |
| ---- | ----- | -------------------------------- |
| data | bytes | Byte data representing the claim |

| Name  | Type                         | Description             |
| ----- | ---------------------------- | ----------------------- |
| claim | struct HypercertMinter.Claim | The parsed Claim struct |
| [1]   | uint8[]                      | Claim metadata URI      |

### \_storeContributorsClaims

```solidity
function _storeContributorsClaims(bytes32 claimHash, address[] creators) internal
```

Stores contributor claims in the `contributorImpacts` mapping; guards against overlapping claims

| Name      | Type      | Description                         |
| --------- | --------- | ----------------------------------- |
| claimHash | bytes32   | Claim data hash-code value          |
| creators  | address[] | Array of addresses for contributors |

### \_hasKey

```solidity
function _hasKey(mapping(bytes32 => string) map, bytes32 key) internal view returns (bool)
```

Checks whether the supplied mapping contains the supplied key

| Name | Type                               | Description       |
| ---- | ---------------------------------- | ----------------- |
| map  | mapping(bytes32 &#x3D;&gt; string) | mapping to search |
| key  | bytes32                            | key to search     |

| Name | Type | Description                            |
| ---- | ---- | -------------------------------------- |
| [0]  | bool | true, if the key exists in the mapping |

## IERC3525MetadataUpgradeable

_Interfaces for any contract that wants to support query of the Uniform Resource Identifier
(URI) for the ERC3525 contract as well as a specified slot.
Because of the higher reliability of data stored in smart contracts compared to data stored in
centralized systems, it is recommended that metadata, including `contractURI`, `slotURI` and
`tokenURI`, be directly returned in JSON format, instead of being returned with a url pointing
to any resource stored in a centralized system.
See https://eips.ethereum.org/EIPS/eip-3525
Note: the ERC-165 identifier for this interface is 0xe1600902._

### contractURI

```solidity
function contractURI() external view returns (string)
```

Returns the Uniform Resource Identifier (URI) for the current ERC3525 contract.

_This function SHOULD return the URI for this contract in JSON format, starting with
header `data:application/json;`.
See https://eips.ethereum.org/EIPS/eip-3525 for the JSON schema for contract URI._

| Name | Type   | Description                                            |
| ---- | ------ | ------------------------------------------------------ |
| [0]  | string | The JSON formatted URI of the current ERC3525 contract |

### slotURI

```solidity
function slotURI(uint256 _slot) external view returns (string)
```

Returns the Uniform Resource Identifier (URI) for the specified slot.

_This function SHOULD return the URI for `_slot` in JSON format, starting with header
`data:application/json;`.
See https://eips.ethereum.org/EIPS/eip-3525 for the JSON schema for slot URI._

| Name | Type   | Description                       |
| ---- | ------ | --------------------------------- |
| [0]  | string | The JSON formatted URI of `_slot` |

## IERC3525Receiver

_Interface for any contract that wants to be informed by EIP-3525 contracts when receiving values from other
addresses.
Note: the EIP-165 identifier for this interface is 0x009ce20b._

### onERC3525Received

```solidity
function onERC3525Received(address _operator, uint256 _fromTokenId, uint256 _toTokenId, uint256 _value, bytes _data) external returns (bytes4)
```

Handle the receipt of an EIP-3525 token value.

_An EIP-3525 smart contract MUST check whether this function is implemented by the recipient contract, if the
recipient contract implements this function, the EIP-3525 contract MUST call this function after a
value transfer (i.e. `transferFrom(uint256,uint256,uint256,bytes)`).
MUST return 0x009ce20b (i.e. `bytes4(keccak256('onERC3525Received(address,uint256,uint256, uint256,bytes)'))`) if the transfer is accepted.
MUST revert or return any value other than 0x009ce20b if the transfer is rejected.
The EIP-3525 smart contract that calls this function MUST revert the transfer transaction if the return value
is not equal to 0x009ce20b._

| Name          | Type    | Description                              |
| ------------- | ------- | ---------------------------------------- |
| \_operator    | address | The address which triggered the transfer |
| \_fromTokenId | uint256 | The token id to transfer value from      |
| \_toTokenId   | uint256 | The token id to transfer value to        |
| \_value       | uint256 | The transferred value                    |
| \_data        | bytes   | Additional data with no specified format |

| Name | Type   | Description                                                                                                      |
| ---- | ------ | ---------------------------------------------------------------------------------------------------------------- |
| [0]  | bytes4 | `bytes4(keccak256('onERC3525Received(address,uint256,uint256,uint256,bytes)'))` unless the transfer is rejected. |

## IERC3525SlotEnumerableUpgradeable

_Interfaces for any contract that wants to support enumeration of slots as well as tokens
with the same slot.
Note: the EIP-165 identifier for this interface is 0x3b741b9e._

### slotCount

```solidity
function slotCount() external view returns (uint256)
```

Get the total amount of slots stored by the contract.

| Name | Type    | Description               |
| ---- | ------- | ------------------------- |
| [0]  | uint256 | The total amount of slots |

### slotByIndex

```solidity
function slotByIndex(uint256 _index) external view returns (uint256)
```

Get the slot at the specified index of all slots stored by the contract.

| Name    | Type    | Description                |
| ------- | ------- | -------------------------- |
| \_index | uint256 | The index in the slot list |

| Name | Type    | Description                       |
| ---- | ------- | --------------------------------- |
| [0]  | uint256 | The slot at `index` of all slots. |

### tokenSupplyInSlot

```solidity
function tokenSupplyInSlot(uint256 _slot) external view returns (uint256)
```

Get the total amount of tokens with the same slot.

| Name   | Type    | Description                        |
| ------ | ------- | ---------------------------------- |
| \_slot | uint256 | The slot to query token supply for |

| Name | Type    | Description                                           |
| ---- | ------- | ----------------------------------------------------- |
| [0]  | uint256 | The total amount of tokens with the specified `_slot` |

### tokenInSlotByIndex

```solidity
function tokenInSlotByIndex(uint256 _slot, uint256 _index) external view returns (uint256)
```

Get the token at the specified index of all tokens with the same slot.

| Name    | Type    | Description                             |
| ------- | ------- | --------------------------------------- |
| \_slot  | uint256 | The slot to query tokens with           |
| \_index | uint256 | The index in the token list of the slot |

| Name | Type    | Description                                         |
| ---- | ------- | --------------------------------------------------- |
| [0]  | uint256 | The token ID at `_index` of all tokens with `_slot` |

## IERC3525Upgradeable

_See https://eips.ethereum.org/EIPS/eip-3525_

### TransferValue

```solidity
event TransferValue(uint256 _fromTokenId, uint256 _toTokenId, uint256 _value)
```

_MUST emit when value of a token is transferred to another token with the same slot,
including zero value transfers (\_value == 0) as well as transfers when tokens are created
(`_fromTokenId` == 0) or destroyed (`_toTokenId` == 0)._

| Name          | Type    | Description                         |
| ------------- | ------- | ----------------------------------- |
| \_fromTokenId | uint256 | The token id to transfer value from |
| \_toTokenId   | uint256 | The token id to transfer value to   |
| \_value       | uint256 | The transferred value               |

### ApprovalValue

```solidity
event ApprovalValue(uint256 _tokenId, address _operator, uint256 _value)
```

_MUST emit when the approval value of a token is set or changed._

| Name       | Type    | Description                                             |
| ---------- | ------- | ------------------------------------------------------- |
| \_tokenId  | uint256 | The token to approve                                    |
| \_operator | address | The operator to approve for                             |
| \_value    | uint256 | The maximum value that `_operator` is allowed to manage |

### SlotChanged

```solidity
event SlotChanged(uint256 _tokenId, uint256 _oldSlot, uint256 _newSlot)
```

_MUST emit when the slot of a token is set or changed._

| Name      | Type    | Description                               |
| --------- | ------- | ----------------------------------------- |
| \_tokenId | uint256 | The token of which slot is set or changed |
| \_oldSlot | uint256 | The previous slot of the token            |
| \_newSlot | uint256 | The updated slot of the token             |

### valueDecimals

```solidity
function valueDecimals() external view returns (uint8)
```

Get the number of decimals the token uses for value - e.g. 6, means the user
representation of the value of a token can be calculated by dividing it by 1,000,000.
Considering the compatibility with third-party wallets, this function is defined as
`valueDecimals()` instead of `decimals()` to avoid conflict with EIP-20 tokens.

| Name | Type  | Description                      |
| ---- | ----- | -------------------------------- |
| [0]  | uint8 | The number of decimals for value |

### balanceOf

```solidity
function balanceOf(uint256 _tokenId) external view returns (uint256)
```

Get the value of a token.

| Name      | Type    | Description                              |
| --------- | ------- | ---------------------------------------- |
| \_tokenId | uint256 | The token for which to query the balance |

| Name | Type    | Description             |
| ---- | ------- | ----------------------- |
| [0]  | uint256 | The value of `_tokenId` |

### slotOf

```solidity
function slotOf(uint256 _tokenId) external view returns (uint256)
```

Get the slot of a token.

| Name      | Type    | Description                |
| --------- | ------- | -------------------------- |
| \_tokenId | uint256 | The identifier for a token |

| Name | Type    | Description           |
| ---- | ------- | --------------------- |
| [0]  | uint256 | The slot of the token |

### approve

```solidity
function approve(uint256 _tokenId, address _operator, uint256 _value) external payable
```

Allow an operator to manage the value of a token, up to the `_value`.

_MUST revert unless caller is the current owner, an authorized operator, or the approved
address for `_tokenId`.
MUST emit the ApprovalValue event._

| Name       | Type    | Description                                                             |
| ---------- | ------- | ----------------------------------------------------------------------- |
| \_tokenId  | uint256 | The token to approve                                                    |
| \_operator | address | The operator to be approved                                             |
| \_value    | uint256 | The maximum value of `_toTokenId` that `_operator` is allowed to manage |

### allowance

```solidity
function allowance(uint256 _tokenId, address _operator) external view returns (uint256)
```

Get the maximum value of a token that an operator is allowed to manage.

| Name       | Type    | Description                                |
| ---------- | ------- | ------------------------------------------ |
| \_tokenId  | uint256 | The token for which to query the allowance |
| \_operator | address | The address of an operator                 |

| Name | Type    | Description                                                                    |
| ---- | ------- | ------------------------------------------------------------------------------ |
| [0]  | uint256 | The current approval value of `_tokenId` that `_operator` is allowed to manage |

### transferFrom

```solidity
function transferFrom(uint256 _fromTokenId, uint256 _toTokenId, uint256 _value) external payable
```

Transfer value from a specified token to another specified token with the same slot.

_Caller MUST be the current owner, an authorized operator or an operator who has been
approved the whole `_fromTokenId` or part of it.
MUST revert if `_fromTokenId` or `_toTokenId` is zero token id or does not exist.
MUST revert if slots of `_fromTokenId` and `_toTokenId` do not match.
MUST revert if `_value` exceeds the balance of `_fromTokenId` or its allowance to the
operator.
MUST emit `TransferValue` event._

| Name          | Type    | Description                      |
| ------------- | ------- | -------------------------------- |
| \_fromTokenId | uint256 | The token to transfer value from |
| \_toTokenId   | uint256 | The token to transfer value to   |
| \_value       | uint256 | The transferred value            |

### transferFrom

```solidity
function transferFrom(uint256 _fromTokenId, address _to, uint256 _value) external payable returns (uint256)
```

Transfer value from a specified token to an address. The caller should confirm that
`_to` is capable of receiving EIP-3525 tokens.

_This function MUST create a new EIP-3525 token with the same slot for `_to`,
or find an existing token with the same slot owned by `_to`, to receive the transferred value.
MUST revert if `_fromTokenId` is zero token id or does not exist.
MUST revert if `_to` is zero address.
MUST revert if `_value` exceeds the balance of `_fromTokenId` or its allowance to the
operator.
MUST emit `Transfer` and `TransferValue` events._

| Name          | Type    | Description                      |
| ------------- | ------- | -------------------------------- |
| \_fromTokenId | uint256 | The token to transfer value from |
| \_to          | address | The address to transfer value to |
| \_value       | uint256 | The transferred value            |

| Name | Type    | Description                                          |
| ---- | ------- | ---------------------------------------------------- |
| [0]  | uint256 | ID of the token which receives the transferred value |

## IHypercertMetadata

### generateSlotURI

```solidity
function generateSlotURI(uint256 slotId) external view returns (string)
```

### generateTokenURI

```solidity
function generateTokenURI(uint256 slotId, uint256 tokenId) external view returns (string)
```

## ArraysUpgradeable

_Collection of functions related to array types._

### getSum

```solidity
function getSum(uint8[] array) internal pure returns (uint256)
```

_calculate the sum of the elements of an array_

### toString

```solidity
function toString(uint64[2] array) internal pure returns (string)
```

### toCsv

```solidity
function toCsv(uint256[] array) internal pure returns (string)
```

### toCsv

```solidity
function toCsv(string[] array) internal pure returns (string)
```

## StringsExtensions

_Collection of functions related to array types._

### toString

```solidity
function toString(bool value) internal pure returns (string)
```

_returns either "true" or "false"_

## NonExistentToken

## NonExistentSlot

## InsufficientBalance

## InsufficientAllowance

## ToZeroAddress

## InvalidID

## AlreadyMinted

## SlotsMismatch

## InvalidApproval

## NotApprovedOrOwner

## ERC3525Upgradeable

## EmptyInput

```solidity
error EmptyInput()
```

## DuplicateScope

```solidity
error DuplicateScope()
```

## InvalidScope

```solidity
error InvalidScope()
```

## InvalidTimeframe

```solidity
error InvalidTimeframe(uint64 from, uint64 to)
```

## ConflictingClaim

```solidity
error ConflictingClaim()
```

## HypercertMinter

Contains functions and events to initialize and issue a hypercertificate

### NAME

```solidity
string NAME
```

Contract name

### SYMBOL

```solidity
string SYMBOL
```

Token symbol

### DECIMALS

```solidity
uint8 DECIMALS
```

Token value decimals

### UPGRADER_ROLE

```solidity
bytes32 UPGRADER_ROLE
```

User role required in order to upgrade the contract

### \_version

```solidity
uint16 _version
```

Current version of the contract

### \_metadata

```solidity
address _metadata
```

Hypercert metadata contract

### workScopes

```solidity
mapping(bytes32 => string) workScopes
```

Mapping of id's to work-scopes

### impactScopes

```solidity
mapping(bytes32 => string) impactScopes
```

Mapping of id's to impact-scopes

### rights

```solidity
mapping(bytes32 => string) rights
```

Mapping of id's to rights

### \_contributorImpacts

```solidity
mapping(address => mapping(bytes32 => bool)) _contributorImpacts
```

### \_impactCerts

```solidity
mapping(uint256 => struct HypercertMinter.Claim) _impactCerts
```

### Claim

```solidity
struct Claim {
  bytes32 claimHash;
  uint64[2] workTimeframe;
  uint64[2] impactTimeframe;
  bytes32[] workScopes;
  bytes32[] impactScopes;
  bytes32[] rights;
  address[] contributors;
  uint256 totalUnits;
  uint16 version;
  bool exists;
  string name;
  string description;
  string uri;
}

```

### ImpactClaimed

```solidity
event ImpactClaimed(uint256 id, address minter, uint8[] fractions)
```

Emitted when an impact is claimed.

| Name      | Type    | Description                                 |
| --------- | ------- | ------------------------------------------- |
| id        | uint256 | Id of the claimed impact.                   |
| minter    | address | Address of cert minter.                     |
| fractions | uint8[] | Units of tokens issued under the hypercert. |

### ImpactScopeAdded

```solidity
event ImpactScopeAdded(bytes32 id, string text)
```

Emitted when a new impact scope is added.

| Name | Type    | Description                          |
| ---- | ------- | ------------------------------------ |
| id   | bytes32 | Id of the impact scope.              |
| text | string  | Short text code of the impact scope. |

### RightAdded

```solidity
event RightAdded(bytes32 id, string text)
```

Emitted when a new right is added.

| Name | Type    | Description                   |
| ---- | ------- | ----------------------------- |
| id   | bytes32 | Id of the right.              |
| text | string  | Short text code of the right. |

### WorkScopeAdded

```solidity
event WorkScopeAdded(bytes32 id, string text)
```

Emitted when a new work scope is added.

| Name | Type    | Description                        |
| ---- | ------- | ---------------------------------- |
| id   | bytes32 | Id of the work scope.              |
| text | string  | Short text code of the work scope. |

### constructor

```solidity
constructor() public
```

Contract constructor logic

### initialize

```solidity
function initialize(address metadataAddress) public
```

Contract initialization logic

### addImpactScope

```solidity
function addImpactScope(string text) public returns (bytes32 id)
```

Adds a new impact scope

| Name | Type   | Description                        |
| ---- | ------ | ---------------------------------- |
| text | string | Text representing the impact scope |

| Name | Type    | Description            |
| ---- | ------- | ---------------------- |
| id   | bytes32 | Id of the impact scope |

### addRight

```solidity
function addRight(string text) public returns (bytes32 id)
```

Adds a new right

| Name | Type   | Description                 |
| ---- | ------ | --------------------------- |
| text | string | Text representing the right |

| Name | Type    | Description     |
| ---- | ------- | --------------- |
| id   | bytes32 | Id of the right |

### addWorkScope

```solidity
function addWorkScope(string text) public returns (bytes32 id)
```

Adds a new work scope

| Name | Type   | Description                      |
| ---- | ------ | -------------------------------- |
| text | string | Text representing the work scope |

| Name | Type    | Description          |
| ---- | ------- | -------------------- |
| id   | bytes32 | Id of the work scope |

### mint

```solidity
function mint(address account, bytes data) public virtual
```

Issues a new hypercertificate

| Name    | Type    | Description                                   |
| ------- | ------- | --------------------------------------------- |
| account | address | Account issuing the new hypercertificate      |
| data    | bytes   | Data representing the parameters of the claim |

### split

```solidity
function split(uint256 tokenId, uint8[] amounts) public
```

### merge

```solidity
function merge(uint256[] tokenIds) public
```

### getImpactCert

```solidity
function getImpactCert(uint256 claimID) public view returns (struct HypercertMinter.Claim)
```

Gets the impact claim with the specified id

| Name    | Type    | Description     |
| ------- | ------- | --------------- |
| claimID | uint256 | Id of the claim |

| Name | Type                         | Description                                        |
| ---- | ---------------------------- | -------------------------------------------------- |
| [0]  | struct HypercertMinter.Claim | The claim, if it doesn't exist with default values |

### version

```solidity
function version() public view virtual returns (uint256)
```

gets the current version of the contract

### updateVersion

```solidity
function updateVersion() external
```

Update the contract version number
Only allowed for member of UPGRADER_ROLE

### supportsInterface

```solidity
function supportsInterface(bytes4 interfaceId) public view returns (bool)
```

Returns a flag indicating if the contract supports the specified interface

| Name        | Type   | Description         |
| ----------- | ------ | ------------------- |
| interfaceId | bytes4 | Id of the interface |

| Name | Type | Description                         |
| ---- | ---- | ----------------------------------- |
| [0]  | bool | true, if the interface is supported |

### name

```solidity
function name() public pure returns (string)
```

### symbol

```solidity
function symbol() public pure returns (string)
```

### valueDecimals

```solidity
function valueDecimals() public view virtual returns (uint8)
```

Get the number of decimals the token uses for value - e.g. 6, means the user
representation of the value of a token can be calculated by dividing it by 1,000,000.
Considering the compatibility with third-party wallets, this function is defined as
`valueDecimals()` instead of `decimals()` to avoid conflict with EIP-20 tokens.

| Name | Type  | Description                      |
| ---- | ----- | -------------------------------- |
| [0]  | uint8 | The number of decimals for value |

### getHash

```solidity
function getHash(uint64[2] workTimeframe_, bytes32[] workScopes_, uint64[2] impactTimeframe_, bytes32[] impactScopes_) public pure virtual returns (bytes32)
```

### slotURI

```solidity
function slotURI(uint256 slotId_) external view returns (string)
```

### tokenURI

```solidity
function tokenURI(uint256 tokenId_) public view returns (string)
```

### \_authorizeUpgrade

```solidity
function _authorizeUpgrade(address) internal view
```

upgrade authorization logic

_adds onlyRole(UPGRADER_ROLE) requirement_

### \_authorizeAdd

```solidity
function _authorizeAdd(string text, mapping(bytes32 => string) map) internal view virtual returns (bytes32 id)
```

Pre-add validation checks

| Name | Type                               | Description                           |
| ---- | ---------------------------------- | ------------------------------------- |
| text | string                             | Text to be added                      |
| map  | mapping(bytes32 &#x3D;&gt; string) | Storage mapping that will be appended |

### \_authorizeMint

```solidity
function _authorizeMint(address account, struct HypercertMinter.Claim claim) internal view virtual
```

Pre-mint validation checks

| Name    | Type                         | Description                      |
| ------- | ---------------------------- | -------------------------------- |
| account | address                      | Destination address for the mint |
| claim   | struct HypercertMinter.Claim | Impact claim data                |

### \_parseData

```solidity
function _parseData(bytes data) internal pure virtual returns (struct HypercertMinter.Claim claim, uint8[])
```

Parse bytes to Claim and URI

_This function is overridable in order to support future schema changes_

| Name | Type  | Description                      |
| ---- | ----- | -------------------------------- |
| data | bytes | Byte data representing the claim |

| Name  | Type                         | Description             |
| ----- | ---------------------------- | ----------------------- |
| claim | struct HypercertMinter.Claim | The parsed Claim struct |
| [1]   | uint8[]                      | Claim metadata URI      |

### \_storeContributorsClaims

```solidity
function _storeContributorsClaims(bytes32 claimHash, address[] creators) internal
```

Stores contributor claims in the `contributorImpacts` mapping; guards against overlapping claims

| Name      | Type      | Description                         |
| --------- | --------- | ----------------------------------- |
| claimHash | bytes32   | Claim data hash-code value          |
| creators  | address[] | Array of addresses for contributors |

### \_hasKey

```solidity
function _hasKey(mapping(bytes32 => string) map, bytes32 key) internal view returns (bool)
```

Checks whether the supplied mapping contains the supplied key

| Name | Type                               | Description       |
| ---- | ---------------------------------- | ----------------- |
| map  | mapping(bytes32 &#x3D;&gt; string) | mapping to search |
| key  | bytes32                            | key to search     |

| Name | Type | Description                            |
| ---- | ---- | -------------------------------------- |
| [0]  | bool | true, if the key exists in the mapping |

## IERC3525MetadataUpgradeable

## IERC3525Receiver

## IERC3525SlotEnumerableUpgradeable

## IERC3525Upgradeable

## IHypercertMetadata

## ArraysUpgradeable

_Collection of functions related to array types._

### getSum

```solidity
function getSum(uint8[] array) internal pure returns (uint256)
```

_calculate the sum of the elements of an array_

### toString

```solidity
function toString(uint64[2] array) internal pure returns (string)
```

### toCsv

```solidity
function toCsv(uint256[] array) internal pure returns (string)
```

### toCsv

```solidity
function toCsv(string[] array) internal pure returns (string)
```

## StringsExtensions

_Collection of functions related to array types._

### toString

```solidity
function toString(bool value) internal pure returns (string)
```

_returns either "true" or "false"_

## HypercertSVG

### SVGParams

```solidity
struct SVGParams {
  string name;
  string[] scopesOfImpact;
  uint64[2] workTimeframe;
  uint64[2] impactTimeframe;
  uint256 units;
  uint256 totalUnits;
}

```

### background

```solidity
mapping(uint256 => string) background
```

_voucher => claimType => background colors_

### backgroundCounter

```solidity
uint256 backgroundCounter
```

### BackgroundAdded

```solidity
event BackgroundAdded(uint256 id)
```

### constructor

```solidity
constructor() public
```

### addBackground

```solidity
function addBackground(string svgString) external returns (uint256 id)
```

### generateSvgHypercert

```solidity
function generateSvgHypercert(string name, string[] scopesOfImpact, uint64[2] workTimeframe, uint64[2] impactTimeframe, uint256 totalUnits) external view virtual returns (string)
```

### generateSvgFraction

```solidity
function generateSvgFraction(string name, string[] scopesOfImpact, uint64[2] workTimeframe, uint64[2] impactTimeframe, uint256 units, uint256 totalUnits) external view virtual returns (string)
```

### \_generateHypercert

```solidity
function _generateHypercert(struct HypercertSVG.SVGParams params) internal view virtual returns (string)
```

### \_generateHypercertFraction

```solidity
function _generateHypercertFraction(struct HypercertSVG.SVGParams params) internal view virtual returns (string)
```

### \_generateBackgroundColor

```solidity
function _generateBackgroundColor() internal pure returns (string)
```

### \_generateBackground

```solidity
function _generateBackground() internal view returns (string)
```

### \_generateHeader

```solidity
function _generateHeader(struct HypercertSVG.SVGParams params) internal pure virtual returns (string)
```

### \_generateName

```solidity
function _generateName(struct HypercertSVG.SVGParams params) internal pure virtual returns (string)
```

### \_generateScopeOfImpact

```solidity
function _generateScopeOfImpact(struct HypercertSVG.SVGParams params) internal pure virtual returns (string)
```

### \_generateFraction

```solidity
function _generateFraction(struct HypercertSVG.SVGParams params) internal view virtual returns (string)
```

### \_generateTotalUnits

```solidity
function _generateTotalUnits(struct HypercertSVG.SVGParams params) internal pure virtual returns (string)
```

### \_generateFooter

```solidity
function _generateFooter(struct HypercertSVG.SVGParams params) internal pure virtual returns (string)
```

### getPercent

```solidity
function getPercent(uint256 part, uint256 whole) public pure returns (uint256 percent)
```

### uint2decimal

```solidity
function uint2decimal(uint256 self, uint8 decimals) internal view returns (bytes)
```

## DateTime

### SECONDS_PER_DAY

```solidity
uint256 SECONDS_PER_DAY
```

### SECONDS_PER_HOUR

```solidity
uint256 SECONDS_PER_HOUR
```

### SECONDS_PER_MINUTE

```solidity
uint256 SECONDS_PER_MINUTE
```

### OFFSET19700101

```solidity
int256 OFFSET19700101
```

### DOW_MON

```solidity
uint256 DOW_MON
```

### DOW_TUE

```solidity
uint256 DOW_TUE
```

### DOW_WED

```solidity
uint256 DOW_WED
```

### DOW_THU

```solidity
uint256 DOW_THU
```

### DOW_FRI

```solidity
uint256 DOW_FRI
```

### DOW_SAT

```solidity
uint256 DOW_SAT
```

### DOW_SUN

```solidity
uint256 DOW_SUN
```

### \_daysFromDate

```solidity
function _daysFromDate(uint256 year, uint256 month, uint256 day) internal pure returns (uint256 _days)
```

### \_daysToDate

```solidity
function _daysToDate(uint256 _days) internal pure returns (uint256 year, uint256 month, uint256 day)
```

### timestampFromDate

```solidity
function timestampFromDate(uint256 year, uint256 month, uint256 day) internal pure returns (uint256 timestamp)
```

### timestampFromDateTime

```solidity
function timestampFromDateTime(uint256 year, uint256 month, uint256 day, uint256 hour, uint256 minute, uint256 second) internal pure returns (uint256 timestamp)
```

### timestampToDate

```solidity
function timestampToDate(uint256 timestamp) internal pure returns (uint256 year, uint256 month, uint256 day)
```

### timestampToDateTime

```solidity
function timestampToDateTime(uint256 timestamp) internal pure returns (uint256 year, uint256 month, uint256 day, uint256 hour, uint256 minute, uint256 second)
```

### isValidDate

```solidity
function isValidDate(uint256 year, uint256 month, uint256 day) internal pure returns (bool valid)
```

### isValidDateTime

```solidity
function isValidDateTime(uint256 year, uint256 month, uint256 day, uint256 hour, uint256 minute, uint256 second) internal pure returns (bool valid)
```

### isLeapYear

```solidity
function isLeapYear(uint256 timestamp) internal pure returns (bool leapYear)
```

### \_isLeapYear

```solidity
function _isLeapYear(uint256 year) internal pure returns (bool leapYear)
```

### isWeekDay

```solidity
function isWeekDay(uint256 timestamp) internal pure returns (bool weekDay)
```

### isWeekEnd

```solidity
function isWeekEnd(uint256 timestamp) internal pure returns (bool weekEnd)
```

### getDaysInMonth

```solidity
function getDaysInMonth(uint256 timestamp) internal pure returns (uint256 daysInMonth)
```

### \_getDaysInMonth

```solidity
function _getDaysInMonth(uint256 year, uint256 month) internal pure returns (uint256 daysInMonth)
```

### getDayOfWeek

```solidity
function getDayOfWeek(uint256 timestamp) internal pure returns (uint256 dayOfWeek)
```

### getYear

```solidity
function getYear(uint256 timestamp) internal pure returns (uint256 year)
```

### getMonth

```solidity
function getMonth(uint256 timestamp) internal pure returns (uint256 month)
```

### getDay

```solidity
function getDay(uint256 timestamp) internal pure returns (uint256 day)
```

### getHour

```solidity
function getHour(uint256 timestamp) internal pure returns (uint256 hour)
```

### getMinute

```solidity
function getMinute(uint256 timestamp) internal pure returns (uint256 minute)
```

### getSecond

```solidity
function getSecond(uint256 timestamp) internal pure returns (uint256 second)
```

### addYears

```solidity
function addYears(uint256 timestamp, uint256 _years) internal pure returns (uint256 newTimestamp)
```

### addMonths

```solidity
function addMonths(uint256 timestamp, uint256 _months) internal pure returns (uint256 newTimestamp)
```

### addDays

```solidity
function addDays(uint256 timestamp, uint256 _days) internal pure returns (uint256 newTimestamp)
```

### addHours

```solidity
function addHours(uint256 timestamp, uint256 _hours) internal pure returns (uint256 newTimestamp)
```

### addMinutes

```solidity
function addMinutes(uint256 timestamp, uint256 _minutes) internal pure returns (uint256 newTimestamp)
```

### addSeconds

```solidity
function addSeconds(uint256 timestamp, uint256 _seconds) internal pure returns (uint256 newTimestamp)
```

### subYears

```solidity
function subYears(uint256 timestamp, uint256 _years) internal pure returns (uint256 newTimestamp)
```

### subMonths

```solidity
function subMonths(uint256 timestamp, uint256 _months) internal pure returns (uint256 newTimestamp)
```

### subDays

```solidity
function subDays(uint256 timestamp, uint256 _days) internal pure returns (uint256 newTimestamp)
```

### subHours

```solidity
function subHours(uint256 timestamp, uint256 _hours) internal pure returns (uint256 newTimestamp)
```

### subMinutes

```solidity
function subMinutes(uint256 timestamp, uint256 _minutes) internal pure returns (uint256 newTimestamp)
```

### subSeconds

```solidity
function subSeconds(uint256 timestamp, uint256 _seconds) internal pure returns (uint256 newTimestamp)
```

### diffYears

```solidity
function diffYears(uint256 fromTimestamp, uint256 toTimestamp) internal pure returns (uint256 _years)
```

### diffMonths

```solidity
function diffMonths(uint256 fromTimestamp, uint256 toTimestamp) internal pure returns (uint256 _months)
```

### diffDays

```solidity
function diffDays(uint256 fromTimestamp, uint256 toTimestamp) internal pure returns (uint256 _days)
```

### diffHours

```solidity
function diffHours(uint256 fromTimestamp, uint256 toTimestamp) internal pure returns (uint256 _hours)
```

### diffMinutes

```solidity
function diffMinutes(uint256 fromTimestamp, uint256 toTimestamp) internal pure returns (uint256 _minutes)
```

### diffSeconds

```solidity
function diffSeconds(uint256 fromTimestamp, uint256 toTimestamp) internal pure returns (uint256 _seconds)
```

## strings

### slice

```solidity
struct slice {
  uint256 _len;
  uint256 _ptr;
}

```

### memcpy

```solidity
function memcpy(uint256 dest, uint256 src, uint256 len) private pure
```

### toSlice

```solidity
function toSlice(string self) internal pure returns (struct strings.slice)
```

### len

```solidity
function len(bytes32 self) internal pure returns (uint256)
```

### toSliceB32

```solidity
function toSliceB32(bytes32 self) internal pure returns (struct strings.slice ret)
```

### copy

```solidity
function copy(struct strings.slice self) internal pure returns (struct strings.slice)
```

### toString

```solidity
function toString(struct strings.slice self) internal pure returns (string)
```

### len

```solidity
function len(struct strings.slice self) internal pure returns (uint256 l)
```

### empty

```solidity
function empty(struct strings.slice self) internal pure returns (bool)
```

### compare

```solidity
function compare(struct strings.slice self, struct strings.slice other) internal pure returns (int256)
```

### equals

```solidity
function equals(struct strings.slice self, struct strings.slice other) internal pure returns (bool)
```

### nextRune

```solidity
function nextRune(struct strings.slice self, struct strings.slice rune) internal pure returns (struct strings.slice)
```

### nextRune

```solidity
function nextRune(struct strings.slice self) internal pure returns (struct strings.slice ret)
```

### ord

```solidity
function ord(struct strings.slice self) internal pure returns (uint256 ret)
```

### keccak

```solidity
function keccak(struct strings.slice self) internal pure returns (bytes32 ret)
```

### startsWith

```solidity
function startsWith(struct strings.slice self, struct strings.slice needle) internal pure returns (bool)
```

### beyond

```solidity
function beyond(struct strings.slice self, struct strings.slice needle) internal pure returns (struct strings.slice)
```

### endsWith

```solidity
function endsWith(struct strings.slice self, struct strings.slice needle) internal pure returns (bool)
```

### until

```solidity
function until(struct strings.slice self, struct strings.slice needle) internal pure returns (struct strings.slice)
```

### findPtr

```solidity
function findPtr(uint256 selflen, uint256 selfptr, uint256 needlelen, uint256 needleptr) private pure returns (uint256)
```

### rfindPtr

```solidity
function rfindPtr(uint256 selflen, uint256 selfptr, uint256 needlelen, uint256 needleptr) private pure returns (uint256)
```

### find

```solidity
function find(struct strings.slice self, struct strings.slice needle) internal pure returns (struct strings.slice)
```

### rfind

```solidity
function rfind(struct strings.slice self, struct strings.slice needle) internal pure returns (struct strings.slice)
```

### split

```solidity
function split(struct strings.slice self, struct strings.slice needle, struct strings.slice token) internal pure returns (struct strings.slice)
```

### split

```solidity
function split(struct strings.slice self, struct strings.slice needle) internal pure returns (struct strings.slice token)
```

### rsplit

```solidity
function rsplit(struct strings.slice self, struct strings.slice needle, struct strings.slice token) internal pure returns (struct strings.slice)
```

### rsplit

```solidity
function rsplit(struct strings.slice self, struct strings.slice needle) internal pure returns (struct strings.slice token)
```

### count

```solidity
function count(struct strings.slice self, struct strings.slice needle) internal pure returns (uint256 cnt)
```

### contains

```solidity
function contains(struct strings.slice self, struct strings.slice needle) internal pure returns (bool)
```

### concat

```solidity
function concat(struct strings.slice self, struct strings.slice other) internal pure returns (string)
```

### join

```solidity
function join(struct strings.slice self, struct strings.slice[] parts) internal pure returns (string)
```

## IHypercertMinter

### Claim

```solidity
struct Claim {
  bytes32 claimHash;
  uint64[2] workTimeframe;
  uint64[2] impactTimeframe;
  bytes32[] workScopes;
  bytes32[] impactScopes;
  bytes32[] rights;
  address[] contributors;
  uint256 totalUnits;
  uint16 version;
  bool exists;
  string name;
  string description;
  string uri;
}

```

### workScopes

```solidity
function workScopes(bytes32 workScopeId) external view returns (string)
```

### impactScopes

```solidity
function impactScopes(bytes32 impactScopeId) external view returns (string)
```

### rights

```solidity
function rights(bytes32 rightsId) external view returns (string)
```

### getImpactCert

```solidity
function getImpactCert(uint256 claimID) external view returns (struct IHypercertMinter.Claim)
```

### balanceOf

```solidity
function balanceOf(uint256 tokenId) external view returns (uint256)
```

## IHypercertSVG

### generateSvgHypercert

```solidity
function generateSvgHypercert(string name, string[] scopesOfImpact, uint64[2] workTimeframe, uint64[2] impactTimeframe, uint256 totalUnits) external view returns (string)
```

### generateSvgFraction

```solidity
function generateSvgFraction(string name, string[] scopesOfImpact, uint64[2] workTimeframe, uint64[2] impactTimeframe, uint256 units, uint256 totalUnits) external view returns (string)
```

## HypercertMetadata

_Hypercertificate metadata creation logic_

### svgGenerator

```solidity
address svgGenerator
```

### constructor

```solidity
constructor(address svgGenerationAddress) public
```

### generateTokenURI

```solidity
function generateTokenURI(uint256 slotId, uint256 tokenId) external view virtual returns (string)
```

### \_hypercertDimensions

```solidity
function _hypercertDimensions(struct IHypercertMinter.Claim claim) internal view returns (string)
```

### generateSlotURI

```solidity
function generateSlotURI(uint256 slotId) external view virtual returns (string)
```

### \_slotProperties

```solidity
function _slotProperties(struct IHypercertMinter.Claim claim) internal view virtual returns (string)
```

### \_tokenProperties

```solidity
function _tokenProperties(struct IHypercertMinter.Claim claim, uint256 units) internal view virtual returns (string)
```

### \_generateImageStringFraction

```solidity
function _generateImageStringFraction(struct IHypercertMinter.Claim claim, uint256 units, string[] impactScopes) internal view returns (string)
```

### \_generateImageStringHypercert

```solidity
function _generateImageStringHypercert(struct IHypercertMinter.Claim claim, string[] scopesOfImpact) internal view returns (string)
```

### \_propertyString

```solidity
function _propertyString(string name_, string description_, string value_, bool isIntrinsic_) internal pure virtual returns (string)
```

### \_propertyString

```solidity
function _propertyString(string name_, string description_, uint256 value_, bool isIntrinsic_) internal pure virtual returns (string)
```

### \_propertyStringRange

```solidity
function _propertyStringRange(string name_, string description_, uint256 value_, uint256 maxValue, bool isIntrinsic_) internal pure virtual returns (string)
```

### \_propertyString

```solidity
function _propertyString(string name_, string description_, bytes32[] value_, bool isIntrinsic_) internal pure virtual returns (string)
```

### \_propertyString

```solidity
function _propertyString(string name_, string description_, uint256[] array_, bool isIntrinsic_) internal pure virtual returns (string)
```

### \_propertyString

```solidity
function _propertyString(string name_, string description_, uint64[2] array_, bool isIntrinsic_) internal pure virtual returns (string)
```

### \_propertyString

```solidity
function _propertyString(string name_, string description_, string[] array_, bool isIntrinsic_) internal pure virtual returns (string)
```

### \_mapWorkScopesIdsToValues

```solidity
function _mapWorkScopesIdsToValues(bytes32[] keys) internal view returns (string)
```

_use keys to look up values in the supplied mapping_

### \_mapImpactScopesIdsToValues

```solidity
function _mapImpactScopesIdsToValues(bytes32[] keys) internal view returns (string)
```

_use keys to look up values in the supplied mapping_

### \_mapRightsIdsToValues

```solidity
function _mapRightsIdsToValues(bytes32[] keys) internal view returns (string)
```

_use keys to look up values in the supplied mapping_

## HypercertSVG

### SVGParams

```solidity
struct SVGParams {
  string name;
  string[] scopesOfImpact;
  uint64[2] workTimeframe;
  uint64[2] impactTimeframe;
  uint256 units;
  uint256 totalUnits;
}

```

### certBgColors

```solidity
mapping(address => mapping(uint8 => string[])) certBgColors
```

_voucher => claimType => background colors_

### background

```solidity
mapping(uint256 => string) background
```

### backgroundCounter

```solidity
uint256 backgroundCounter
```

### BackgroundAdded

```solidity
event BackgroundAdded(uint256 id)
```

### constructor

```solidity
constructor() public
```

### addBackground

```solidity
function addBackground(string svgString) external returns (uint256 id)
```

### generateSvgHypercert

```solidity
function generateSvgHypercert(string name, string[] scopesOfImpact, uint64[2] workTimeframe, uint64[2] impactTimeframe, uint256 totalUnits) external view virtual returns (string)
```

### generateSvgFraction

```solidity
function generateSvgFraction(string name, string[] scopesOfImpact, uint64[2] workTimeframe, uint64[2] impactTimeframe, uint256 units, uint256 totalUnits) external view virtual returns (string)
```

### \_generateHypercert

```solidity
function _generateHypercert(struct HypercertSVG.SVGParams params) internal view virtual returns (string)
```

### \_generateHypercertFraction

```solidity
function _generateHypercertFraction(struct HypercertSVG.SVGParams params) internal view virtual returns (string)
```

### \_generateBackgroundColor

```solidity
function _generateBackgroundColor() internal pure returns (string)
```

### \_generateBackground

```solidity
function _generateBackground() internal pure virtual returns (string)
```

### \_generateHeader

```solidity
function _generateHeader(struct HypercertSVG.SVGParams params) internal pure virtual returns (string)
```

### \_generateName

```solidity
function _generateName(struct HypercertSVG.SVGParams params) internal view virtual returns (string)
```

### \_generateScopeOfImpact

```solidity
function _generateScopeOfImpact(struct HypercertSVG.SVGParams params) internal view virtual returns (string)
```

### \_generateFraction

```solidity
function _generateFraction(struct HypercertSVG.SVGParams params) internal pure virtual returns (string)
```

### \_generateTotalUnits

```solidity
function _generateTotalUnits(struct HypercertSVG.SVGParams params) internal pure virtual returns (string)
```

### \_generateFooter

```solidity
function _generateFooter(struct HypercertSVG.SVGParams params) internal pure virtual returns (string)
```

## IHypercertMetadata

### generateSlotURI

```solidity
function generateSlotURI(uint256 slotId) external view returns (string)
```

### generateTokenURI

```solidity
function generateTokenURI(uint256 slotId, uint256 tokenId) external view returns (string)
```

## DateTime

### SECONDS_PER_DAY

```solidity
uint256 SECONDS_PER_DAY
```

### SECONDS_PER_HOUR

```solidity
uint256 SECONDS_PER_HOUR
```

### SECONDS_PER_MINUTE

```solidity
uint256 SECONDS_PER_MINUTE
```

### OFFSET19700101

```solidity
int256 OFFSET19700101
```

### DOW_MON

```solidity
uint256 DOW_MON
```

### DOW_TUE

```solidity
uint256 DOW_TUE
```

### DOW_WED

```solidity
uint256 DOW_WED
```

### DOW_THU

```solidity
uint256 DOW_THU
```

### DOW_FRI

```solidity
uint256 DOW_FRI
```

### DOW_SAT

```solidity
uint256 DOW_SAT
```

### DOW_SUN

```solidity
uint256 DOW_SUN
```

### \_daysFromDate

```solidity
function _daysFromDate(uint256 year, uint256 month, uint256 day) internal pure returns (uint256 _days)
```

### \_daysToDate

```solidity
function _daysToDate(uint256 _days) internal pure returns (uint256 year, uint256 month, uint256 day)
```

### timestampFromDate

```solidity
function timestampFromDate(uint256 year, uint256 month, uint256 day) internal pure returns (uint256 timestamp)
```

### timestampFromDateTime

```solidity
function timestampFromDateTime(uint256 year, uint256 month, uint256 day, uint256 hour, uint256 minute, uint256 second) internal pure returns (uint256 timestamp)
```

### timestampToDate

```solidity
function timestampToDate(uint256 timestamp) internal pure returns (uint256 year, uint256 month, uint256 day)
```

### timestampToDateTime

```solidity
function timestampToDateTime(uint256 timestamp) internal pure returns (uint256 year, uint256 month, uint256 day, uint256 hour, uint256 minute, uint256 second)
```

### isValidDate

```solidity
function isValidDate(uint256 year, uint256 month, uint256 day) internal pure returns (bool valid)
```

### isValidDateTime

```solidity
function isValidDateTime(uint256 year, uint256 month, uint256 day, uint256 hour, uint256 minute, uint256 second) internal pure returns (bool valid)
```

### isLeapYear

```solidity
function isLeapYear(uint256 timestamp) internal pure returns (bool leapYear)
```

### \_isLeapYear

```solidity
function _isLeapYear(uint256 year) internal pure returns (bool leapYear)
```

### isWeekDay

```solidity
function isWeekDay(uint256 timestamp) internal pure returns (bool weekDay)
```

### isWeekEnd

```solidity
function isWeekEnd(uint256 timestamp) internal pure returns (bool weekEnd)
```

### getDaysInMonth

```solidity
function getDaysInMonth(uint256 timestamp) internal pure returns (uint256 daysInMonth)
```

### \_getDaysInMonth

```solidity
function _getDaysInMonth(uint256 year, uint256 month) internal pure returns (uint256 daysInMonth)
```

### getDayOfWeek

```solidity
function getDayOfWeek(uint256 timestamp) internal pure returns (uint256 dayOfWeek)
```

### getYear

```solidity
function getYear(uint256 timestamp) internal pure returns (uint256 year)
```

### getMonth

```solidity
function getMonth(uint256 timestamp) internal pure returns (uint256 month)
```

### getDay

```solidity
function getDay(uint256 timestamp) internal pure returns (uint256 day)
```

### getHour

```solidity
function getHour(uint256 timestamp) internal pure returns (uint256 hour)
```

### getMinute

```solidity
function getMinute(uint256 timestamp) internal pure returns (uint256 minute)
```

### getSecond

```solidity
function getSecond(uint256 timestamp) internal pure returns (uint256 second)
```

### addYears

```solidity
function addYears(uint256 timestamp, uint256 _years) internal pure returns (uint256 newTimestamp)
```

### addMonths

```solidity
function addMonths(uint256 timestamp, uint256 _months) internal pure returns (uint256 newTimestamp)
```

### addDays

```solidity
function addDays(uint256 timestamp, uint256 _days) internal pure returns (uint256 newTimestamp)
```

### addHours

```solidity
function addHours(uint256 timestamp, uint256 _hours) internal pure returns (uint256 newTimestamp)
```

### addMinutes

```solidity
function addMinutes(uint256 timestamp, uint256 _minutes) internal pure returns (uint256 newTimestamp)
```

### addSeconds

```solidity
function addSeconds(uint256 timestamp, uint256 _seconds) internal pure returns (uint256 newTimestamp)
```

### subYears

```solidity
function subYears(uint256 timestamp, uint256 _years) internal pure returns (uint256 newTimestamp)
```

### subMonths

```solidity
function subMonths(uint256 timestamp, uint256 _months) internal pure returns (uint256 newTimestamp)
```

### subDays

```solidity
function subDays(uint256 timestamp, uint256 _days) internal pure returns (uint256 newTimestamp)
```

### subHours

```solidity
function subHours(uint256 timestamp, uint256 _hours) internal pure returns (uint256 newTimestamp)
```

### subMinutes

```solidity
function subMinutes(uint256 timestamp, uint256 _minutes) internal pure returns (uint256 newTimestamp)
```

### subSeconds

```solidity
function subSeconds(uint256 timestamp, uint256 _seconds) internal pure returns (uint256 newTimestamp)
```

### diffYears

```solidity
function diffYears(uint256 fromTimestamp, uint256 toTimestamp) internal pure returns (uint256 _years)
```

### diffMonths

```solidity
function diffMonths(uint256 fromTimestamp, uint256 toTimestamp) internal pure returns (uint256 _months)
```

### diffDays

```solidity
function diffDays(uint256 fromTimestamp, uint256 toTimestamp) internal pure returns (uint256 _days)
```

### diffHours

```solidity
function diffHours(uint256 fromTimestamp, uint256 toTimestamp) internal pure returns (uint256 _hours)
```

### diffMinutes

```solidity
function diffMinutes(uint256 fromTimestamp, uint256 toTimestamp) internal pure returns (uint256 _minutes)
```

### diffSeconds

```solidity
function diffSeconds(uint256 fromTimestamp, uint256 toTimestamp) internal pure returns (uint256 _seconds)
```

## strings

### slice

```solidity
struct slice {
  uint256 _len;
  uint256 _ptr;
}

```

### memcpy

```solidity
function memcpy(uint256 dest, uint256 src, uint256 len) private pure
```

### toSlice

```solidity
function toSlice(string self) internal pure returns (struct strings.slice)
```

### len

```solidity
function len(bytes32 self) internal pure returns (uint256)
```

### toSliceB32

```solidity
function toSliceB32(bytes32 self) internal pure returns (struct strings.slice ret)
```

### copy

```solidity
function copy(struct strings.slice self) internal pure returns (struct strings.slice)
```

### toString

```solidity
function toString(struct strings.slice self) internal pure returns (string)
```

### len

```solidity
function len(struct strings.slice self) internal pure returns (uint256 l)
```

### empty

```solidity
function empty(struct strings.slice self) internal pure returns (bool)
```

### compare

```solidity
function compare(struct strings.slice self, struct strings.slice other) internal pure returns (int256)
```

### equals

```solidity
function equals(struct strings.slice self, struct strings.slice other) internal pure returns (bool)
```

### nextRune

```solidity
function nextRune(struct strings.slice self, struct strings.slice rune) internal pure returns (struct strings.slice)
```

### nextRune

```solidity
function nextRune(struct strings.slice self) internal pure returns (struct strings.slice ret)
```

### ord

```solidity
function ord(struct strings.slice self) internal pure returns (uint256 ret)
```

### keccak

```solidity
function keccak(struct strings.slice self) internal pure returns (bytes32 ret)
```

### startsWith

```solidity
function startsWith(struct strings.slice self, struct strings.slice needle) internal pure returns (bool)
```

### beyond

```solidity
function beyond(struct strings.slice self, struct strings.slice needle) internal pure returns (struct strings.slice)
```

### endsWith

```solidity
function endsWith(struct strings.slice self, struct strings.slice needle) internal pure returns (bool)
```

### until

```solidity
function until(struct strings.slice self, struct strings.slice needle) internal pure returns (struct strings.slice)
```

### findPtr

```solidity
function findPtr(uint256 selflen, uint256 selfptr, uint256 needlelen, uint256 needleptr) private pure returns (uint256)
```

### rfindPtr

```solidity
function rfindPtr(uint256 selflen, uint256 selfptr, uint256 needlelen, uint256 needleptr) private pure returns (uint256)
```

### find

```solidity
function find(struct strings.slice self, struct strings.slice needle) internal pure returns (struct strings.slice)
```

### rfind

```solidity
function rfind(struct strings.slice self, struct strings.slice needle) internal pure returns (struct strings.slice)
```

### split

```solidity
function split(struct strings.slice self, struct strings.slice needle, struct strings.slice token) internal pure returns (struct strings.slice)
```

### split

```solidity
function split(struct strings.slice self, struct strings.slice needle) internal pure returns (struct strings.slice token)
```

### rsplit

```solidity
function rsplit(struct strings.slice self, struct strings.slice needle, struct strings.slice token) internal pure returns (struct strings.slice)
```

### rsplit

```solidity
function rsplit(struct strings.slice self, struct strings.slice needle) internal pure returns (struct strings.slice token)
```

### count

```solidity
function count(struct strings.slice self, struct strings.slice needle) internal pure returns (uint256 cnt)
```

### contains

```solidity
function contains(struct strings.slice self, struct strings.slice needle) internal pure returns (bool)
```

### concat

```solidity
function concat(struct strings.slice self, struct strings.slice other) internal pure returns (string)
```

### join

```solidity
function join(struct strings.slice self, struct strings.slice[] parts) internal pure returns (string)
```

## ArraysUpgradeable

_Collection of functions related to array types._

### getSum

```solidity
function getSum(uint8[] array) internal pure returns (uint256)
```

_calculate the sum of the elements of an array_

### toString

```solidity
function toString(uint64[2] array) internal pure returns (string)
```

### toCsv

```solidity
function toCsv(uint256[] array) internal pure returns (string)
```

### toCsv

```solidity
function toCsv(string[] array) internal pure returns (string)
```

## StringsExtensions

_Collection of functions related to array types._

### toString

```solidity
function toString(bool value) internal pure returns (string)
```

_returns either "true" or "false"_

## NonExistentToken

```solidity
error NonExistentToken(uint256 tokenId)
```

## NonExistentSlot

```solidity
error NonExistentSlot(uint256 slotId)
```

## InsufficientBalance

```solidity
error InsufficientBalance(uint256 transferAmount, uint256 balance)
```

## InsufficientAllowance

```solidity
error InsufficientAllowance(uint256 transferAmount, uint256 allowance)
```

## ToZeroAddress

```solidity
error ToZeroAddress()
```

## InvalidID

```solidity
error InvalidID(uint256 tokenId)
```

## AlreadyMinted

```solidity
error AlreadyMinted(uint256 tokenId)
```

## SlotsMismatch

```solidity
error SlotsMismatch(uint256 fromTokenId, uint256 toTokenId)
```

## InvalidApproval

```solidity
error InvalidApproval(uint256 tokenId, address from, address to)
```

## NotApprovedOrOwner

```solidity
error NotApprovedOrOwner()
```

## ERC3525Upgradeable

### ApproveData

```solidity
struct ApproveData {
  address[] approvals;
  mapping(address => uint256) allowances;
}

```

### \_values

```solidity
mapping(uint256 => uint256) _values
```

_tokenId => values_

### \_approvedValues

```solidity
mapping(uint256 => struct ERC3525Upgradeable.ApproveData) _approvedValues
```

_tokenId => operator => units_

### \_slots

```solidity
mapping(uint256 => uint256) _slots
```

_tokenId => slot_

### \_slotArray

```solidity
uint256[] _slotArray
```

### \_tokensBySlot

```solidity
mapping(uint256 => uint256[]) _tokensBySlot
```

_slot => tokenId[]_

### supportsInterface

```solidity
function supportsInterface(bytes4 interfaceId) public view virtual returns (bool)
```

### balanceOf

```solidity
function balanceOf(uint256 tokenId_) public view virtual returns (uint256)
```

### slotOf

```solidity
function slotOf(uint256 tokenId_) public view virtual returns (uint256)
```

### approve

```solidity
function approve(uint256 tokenId_, address to_, uint256 value_) external payable virtual
```

### allowance

```solidity
function allowance(uint256 tokenId_, address operator_) public view virtual returns (uint256)
```

### slotCount

```solidity
function slotCount() external view virtual returns (uint256)
```

Get the total amount of slots stored by the contract.

| Name | Type    | Description               |
| ---- | ------- | ------------------------- |
| [0]  | uint256 | The total amount of slots |

### slotByIndex

```solidity
function slotByIndex(uint256 _index) external view virtual returns (uint256)
```

Get the slot at the specified index of all slots stored by the contract.

| Name    | Type    | Description                |
| ------- | ------- | -------------------------- |
| \_index | uint256 | The index in the slot list |

| Name | Type    | Description                       |
| ---- | ------- | --------------------------------- |
| [0]  | uint256 | The slot at `index` of all slots. |

### tokenSupplyInSlot

```solidity
function tokenSupplyInSlot(uint256 _slot) external view virtual returns (uint256)
```

Get the total amount of tokens with the same slot.

| Name   | Type    | Description                        |
| ------ | ------- | ---------------------------------- |
| \_slot | uint256 | The slot to query token supply for |

| Name | Type    | Description                                           |
| ---- | ------- | ----------------------------------------------------- |
| [0]  | uint256 | The total amount of tokens with the specified `_slot` |

### tokenInSlotByIndex

```solidity
function tokenInSlotByIndex(uint256 _slot, uint256 _index) external view virtual returns (uint256)
```

Get the token at the specified index of all tokens with the same slot.

| Name    | Type    | Description                             |
| ------- | ------- | --------------------------------------- |
| \_slot  | uint256 | The slot to query tokens with           |
| \_index | uint256 | The index in the token list of the slot |

| Name | Type    | Description                                         |
| ---- | ------- | --------------------------------------------------- |
| [0]  | uint256 | The token ID at `_index` of all tokens with `_slot` |

### tokenFractions

```solidity
function tokenFractions(uint256 _slot) internal view virtual returns (uint256[])
```

### transferFrom

```solidity
function transferFrom(uint256 fromTokenId_, address to_, uint256 value_) public payable virtual returns (uint256 newTokenId)
```

### transferFrom

```solidity
function transferFrom(uint256 fromTokenId_, uint256 toTokenId_, uint256 value_) public payable virtual
```

### contractURI

```solidity
function contractURI() public view virtual returns (string)
```

Returns the Uniform Resource Identifier (URI) for the current ERC3525 contract.

_This function SHOULD return the URI for this contract in JSON format, starting with
header `data:application/json;`.
See https://eips.ethereum.org/EIPS/eip-3525 for the JSON schema for contract URI._

| Name | Type   | Description                                            |
| ---- | ------ | ------------------------------------------------------ |
| [0]  | string | The JSON formatted URI of the current ERC3525 contract |

### \_mint

```solidity
function _mint(address to_, uint256 tokenId_, uint256 slot_) private
```

### \_mintValue

```solidity
function _mintValue(address to_, uint256 tokenId_, uint256 slot_, uint256 value_) internal virtual
```

### \_burn

```solidity
function _burn(uint256 tokenId_) internal virtual
```

### \_transfer

```solidity
function _transfer(uint256 fromTokenId_, uint256 toTokenId_, uint256 value_) internal virtual
```

### \_spendAllowance

```solidity
function _spendAllowance(address operator_, uint256 tokenId_, uint256 value_) internal virtual
```

### \_approveValue

```solidity
function _approveValue(uint256 tokenId_, address to_, uint256 value_) internal virtual
```

### \_getNewTokenId

```solidity
function _getNewTokenId(uint256) internal virtual returns (uint256)
```

### \_beforeTokenTransfer

```solidity
function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual
```

### \_checkOnERC3525Received

```solidity
function _checkOnERC3525Received(uint256 fromTokenId_, uint256 toTokenId_, uint256 value_, bytes data_) private returns (bool)
```

### \_beforeValueTransfer

```solidity
function _beforeValueTransfer(address from_, address to_, uint256 fromTokenId_, uint256 toTokenId_, uint256 slot_, uint256 value_) internal virtual
```

### \_afterValueTransfer

```solidity
function _afterValueTransfer(address from_, address to_, uint256 fromTokenId_, uint256 toTokenId_, uint256 slot_, uint256 value_) internal virtual
```

## IHypercertMinter

### Claim

```solidity
struct Claim {
  bytes32 claimHash;
  uint64[2] workTimeframe;
  uint64[2] impactTimeframe;
  bytes32[] workScopes;
  bytes32[] impactScopes;
  bytes32[] rights;
  address[] contributors;
  uint256 totalUnits;
  uint16 version;
  bool exists;
  string name;
  string description;
  string uri;
}

```

### workScopes

```solidity
function workScopes(bytes32 workScopeId) external view returns (string)
```

### impactScopes

```solidity
function impactScopes(bytes32 impactScopeId) external view returns (string)
```

### rights

```solidity
function rights(bytes32 rightsId) external view returns (string)
```

### getImpactCert

```solidity
function getImpactCert(uint256 claimID) external view returns (struct IHypercertMinter.Claim)
```

### balanceOf

```solidity
function balanceOf(uint256 tokenId) external view returns (uint256)
```

## IHypercertSVG

### generateSvgHypercert

```solidity
function generateSvgHypercert(string name, string description, uint64[2] workTimeframe, uint64[2] impactTimeframe, uint256 totalUnits) external view returns (string)
```

### generateSvgFraction

```solidity
function generateSvgFraction(string name, string description, uint64[2] workTimeframe, uint64[2] impactTimeframe, uint256 units, uint256 totalUnits) external view returns (string)
```

## HypercertMetadata

_Hypercertificate metadata creation logic_

### svgGenerator

```solidity
address svgGenerator
```

### constructor

```solidity
constructor(address svgGenerationAddress) public
```

### generateTokenURI

```solidity
function generateTokenURI(uint256 slotId, uint256 tokenId) external view virtual returns (string)
```

### \_hypercertDimensions

```solidity
function _hypercertDimensions(struct IHypercertMinter.Claim claim) internal view returns (string)
```

### generateSlotURI

```solidity
function generateSlotURI(uint256 slotId) external view virtual returns (string)
```

### \_slotProperties

```solidity
function _slotProperties(struct IHypercertMinter.Claim claim) internal view virtual returns (string)
```

### \_tokenProperties

```solidity
function _tokenProperties(struct IHypercertMinter.Claim claim, uint256 units) internal view virtual returns (string)
```

### \_generateImageStringFraction

```solidity
function _generateImageStringFraction(struct IHypercertMinter.Claim claim, uint256 units) internal view returns (string)
```

### \_generateImageStringHypercert

```solidity
function _generateImageStringHypercert(struct IHypercertMinter.Claim claim) internal view returns (string)
```

### \_propertyString

```solidity
function _propertyString(string name_, string description_, string value_, bool isIntrinsic_) internal pure virtual returns (string)
```

### \_propertyString

```solidity
function _propertyString(string name_, string description_, uint256 value_, bool isIntrinsic_) internal pure virtual returns (string)
```

### \_propertyStringRange

```solidity
function _propertyStringRange(string name_, string description_, uint256 value_, uint256 maxValue, bool isIntrinsic_) internal pure virtual returns (string)
```

### \_propertyString

```solidity
function _propertyString(string name_, string description_, bytes32[] value_, bool isIntrinsic_) internal pure virtual returns (string)
```

### \_propertyString

```solidity
function _propertyString(string name_, string description_, uint256[] array_, bool isIntrinsic_) internal pure virtual returns (string)
```

### \_propertyString

```solidity
function _propertyString(string name_, string description_, uint64[2] array_, bool isIntrinsic_) internal pure virtual returns (string)
```

### \_propertyString

```solidity
function _propertyString(string name_, string description_, string[] array_, bool isIntrinsic_) internal pure virtual returns (string)
```

### \_mapWorkScopesIdsToValues

```solidity
function _mapWorkScopesIdsToValues(bytes32[] keys) internal view returns (string)
```

_use keys to look up values in the supplied mapping_

### \_mapImpactScopesIdsToValues

```solidity
function _mapImpactScopesIdsToValues(bytes32[] keys) internal view returns (string)
```

_use keys to look up values in the supplied mapping_

### \_mapRightsIdsToValues

```solidity
function _mapRightsIdsToValues(bytes32[] keys) internal view returns (string)
```

_use keys to look up values in the supplied mapping_

## EmptyInput

```solidity
error EmptyInput()
```

## DuplicateScope

```solidity
error DuplicateScope()
```

## InvalidScope

```solidity
error InvalidScope()
```

## InvalidTimeframe

```solidity
error InvalidTimeframe(uint64 from, uint64 to)
```

## ConflictingClaim

```solidity
error ConflictingClaim()
```

## HypercertMinter

Contains functions and events to initialize and issue a hypercertificate

### NAME

```solidity
string NAME
```

Contract name

### SYMBOL

```solidity
string SYMBOL
```

Token symbol

### DECIMALS

```solidity
uint8 DECIMALS
```

Token value decimals

### UPGRADER_ROLE

```solidity
bytes32 UPGRADER_ROLE
```

User role required in order to upgrade the contract

### \_version

```solidity
uint16 _version
```

Current version of the contract

### \_metadata

```solidity
address _metadata
```

Hypercert metadata contract

### workScopes

```solidity
mapping(bytes32 => string) workScopes
```

Mapping of id's to work-scopes

### impactScopes

```solidity
mapping(bytes32 => string) impactScopes
```

Mapping of id's to impact-scopes

### rights

```solidity
mapping(bytes32 => string) rights
```

Mapping of id's to rights

### \_contributorImpacts

```solidity
mapping(address => mapping(bytes32 => bool)) _contributorImpacts
```

### \_impactCerts

```solidity
mapping(uint256 => struct HypercertMinter.Claim) _impactCerts
```

### Claim

```solidity
struct Claim {
  bytes32 claimHash;
  uint64[2] workTimeframe;
  uint64[2] impactTimeframe;
  bytes32[] workScopes;
  bytes32[] impactScopes;
  bytes32[] rights;
  address[] contributors;
  uint256 totalUnits;
  uint16 version;
  bool exists;
  string name;
  string description;
  string uri;
}

```

### ImpactClaimed

```solidity
event ImpactClaimed(uint256 id, address minter, uint8[] fractions)
```

Emitted when an impact is claimed.

| Name      | Type    | Description                                 |
| --------- | ------- | ------------------------------------------- |
| id        | uint256 | Id of the claimed impact.                   |
| minter    | address | Address of cert minter.                     |
| fractions | uint8[] | Units of tokens issued under the hypercert. |

### ImpactScopeAdded

```solidity
event ImpactScopeAdded(bytes32 id, string text)
```

Emitted when a new impact scope is added.

| Name | Type    | Description                          |
| ---- | ------- | ------------------------------------ |
| id   | bytes32 | Id of the impact scope.              |
| text | string  | Short text code of the impact scope. |

### RightAdded

```solidity
event RightAdded(bytes32 id, string text)
```

Emitted when a new right is added.

| Name | Type    | Description                   |
| ---- | ------- | ----------------------------- |
| id   | bytes32 | Id of the right.              |
| text | string  | Short text code of the right. |

### WorkScopeAdded

```solidity
event WorkScopeAdded(bytes32 id, string text)
```

Emitted when a new work scope is added.

| Name | Type    | Description                        |
| ---- | ------- | ---------------------------------- |
| id   | bytes32 | Id of the work scope.              |
| text | string  | Short text code of the work scope. |

### constructor

```solidity
constructor() public
```

Contract constructor logic

### initialize

```solidity
function initialize(address metadataAddress) public
```

Contract initialization logic

### addImpactScope

```solidity
function addImpactScope(string text) public returns (bytes32 id)
```

Adds a new impact scope

| Name | Type   | Description                        |
| ---- | ------ | ---------------------------------- |
| text | string | Text representing the impact scope |

| Name | Type    | Description            |
| ---- | ------- | ---------------------- |
| id   | bytes32 | Id of the impact scope |

### addRight

```solidity
function addRight(string text) public returns (bytes32 id)
```

Adds a new right

| Name | Type   | Description                 |
| ---- | ------ | --------------------------- |
| text | string | Text representing the right |

| Name | Type    | Description     |
| ---- | ------- | --------------- |
| id   | bytes32 | Id of the right |

### addWorkScope

```solidity
function addWorkScope(string text) public returns (bytes32 id)
```

Adds a new work scope

| Name | Type   | Description                      |
| ---- | ------ | -------------------------------- |
| text | string | Text representing the work scope |

| Name | Type    | Description          |
| ---- | ------- | -------------------- |
| id   | bytes32 | Id of the work scope |

### mint

```solidity
function mint(address account, bytes data) public virtual
```

Issues a new hypercertificate

| Name    | Type    | Description                                   |
| ------- | ------- | --------------------------------------------- |
| account | address | Account issuing the new hypercertificate      |
| data    | bytes   | Data representing the parameters of the claim |

### getImpactCert

```solidity
function getImpactCert(uint256 claimID) public view returns (struct HypercertMinter.Claim)
```

Gets the impact claim with the specified id

| Name    | Type    | Description     |
| ------- | ------- | --------------- |
| claimID | uint256 | Id of the claim |

| Name | Type                         | Description                                        |
| ---- | ---------------------------- | -------------------------------------------------- |
| [0]  | struct HypercertMinter.Claim | The claim, if it doesn't exist with default values |

### version

```solidity
function version() public view virtual returns (uint256)
```

gets the current version of the contract

### updateVersion

```solidity
function updateVersion() external
```

Update the contract version number
Only allowed for member of UPGRADER_ROLE

### supportsInterface

```solidity
function supportsInterface(bytes4 interfaceId) public view returns (bool)
```

Returns a flag indicating if the contract supports the specified interface

| Name        | Type   | Description         |
| ----------- | ------ | ------------------- |
| interfaceId | bytes4 | Id of the interface |

| Name | Type | Description                         |
| ---- | ---- | ----------------------------------- |
| [0]  | bool | true, if the interface is supported |

### name

```solidity
function name() public pure returns (string)
```

### symbol

```solidity
function symbol() public pure returns (string)
```

### valueDecimals

```solidity
function valueDecimals() public view virtual returns (uint8)
```

Get the number of decimals the token uses for value - e.g. 6, means the user
representation of the value of a token can be calculated by dividing it by 1,000,000.
Considering the compatibility with third-party wallets, this function is defined as
`valueDecimals()` instead of `decimals()` to avoid conflict with EIP-20 tokens.

| Name | Type  | Description                      |
| ---- | ----- | -------------------------------- |
| [0]  | uint8 | The number of decimals for value |

### getHash

```solidity
function getHash(uint64[2] workTimeframe_, bytes32[] workScopes_, uint64[2] impactTimeframe_, bytes32[] impactScopes_) public pure virtual returns (bytes32)
```

### slotURI

```solidity
function slotURI(uint256 slotId_) external view returns (string)
```

### tokenURI

```solidity
function tokenURI(uint256 tokenId_) public view returns (string)
```

### \_authorizeUpgrade

```solidity
function _authorizeUpgrade(address) internal view
```

upgrade authorization logic

_adds onlyRole(UPGRADER_ROLE) requirement_

### \_authorizeAdd

```solidity
function _authorizeAdd(string text, mapping(bytes32 => string) map) internal view virtual returns (bytes32 id)
```

Pre-add validation checks

| Name | Type                               | Description                           |
| ---- | ---------------------------------- | ------------------------------------- |
| text | string                             | Text to be added                      |
| map  | mapping(bytes32 &#x3D;&gt; string) | Storage mapping that will be appended |

### \_authorizeMint

```solidity
function _authorizeMint(address account, struct HypercertMinter.Claim claim) internal view virtual
```

Pre-mint validation checks

| Name    | Type                         | Description                      |
| ------- | ---------------------------- | -------------------------------- |
| account | address                      | Destination address for the mint |
| claim   | struct HypercertMinter.Claim | Impact claim data                |

### \_parseData

```solidity
function _parseData(bytes data) internal pure virtual returns (struct HypercertMinter.Claim claim, uint8[])
```

Parse bytes to Claim and URI

_This function is overridable in order to support future schema changes_

| Name | Type  | Description                      |
| ---- | ----- | -------------------------------- |
| data | bytes | Byte data representing the claim |

| Name  | Type                         | Description             |
| ----- | ---------------------------- | ----------------------- |
| claim | struct HypercertMinter.Claim | The parsed Claim struct |
| [1]   | uint8[]                      | Claim metadata URI      |

### \_storeContributorsClaims

```solidity
function _storeContributorsClaims(bytes32 claimHash, address[] creators) internal
```

Stores contributor claims in the `contributorImpacts` mapping; guards against overlapping claims

| Name      | Type      | Description                         |
| --------- | --------- | ----------------------------------- |
| claimHash | bytes32   | Claim data hash-code value          |
| creators  | address[] | Array of addresses for contributors |

### \_hasKey

```solidity
function _hasKey(mapping(bytes32 => string) map, bytes32 key) internal view returns (bool)
```

Checks whether the supplied mapping contains the supplied key

| Name | Type                               | Description       |
| ---- | ---------------------------------- | ----------------- |
| map  | mapping(bytes32 &#x3D;&gt; string) | mapping to search |
| key  | bytes32                            | key to search     |

| Name | Type | Description                            |
| ---- | ---- | -------------------------------------- |
| [0]  | bool | true, if the key exists in the mapping |

## HypercertSVG

### SVGParams

```solidity
struct SVGParams {
  string name;
  string description;
  uint64[2] workTimeframe;
  uint64[2] impactTimeframe;
  uint256 units;
  uint256 totalUnits;
}

```

### certBgColors

```solidity
mapping(address => mapping(uint8 => string[])) certBgColors
```

_voucher => claimType => background colors_

### background

```solidity
mapping(uint256 => string) background
```

### backgroundCounter

```solidity
uint256 backgroundCounter
```

### BackgroundAdded

```solidity
event BackgroundAdded(uint256 id)
```

### constructor

```solidity
constructor() public
```

### addBackground

```solidity
function addBackground(string svgString) external returns (uint256 id)
```

### generateSvgHypercert

```solidity
function generateSvgHypercert(string name, string description, uint64[2] workTimeframe, uint64[2] impactTimeframe, uint256 totalUnits) external view virtual returns (string)
```

### generateSvgFraction

```solidity
function generateSvgFraction(string name, string description, uint64[2] workTimeframe, uint64[2] impactTimeframe, uint256 units, uint256 totalUnits) external view virtual returns (string)
```

### \_generateHypercert

```solidity
function _generateHypercert(struct HypercertSVG.SVGParams params) internal view virtual returns (string)
```

### \_generateHypercertFraction

```solidity
function _generateHypercertFraction(struct HypercertSVG.SVGParams params) internal view virtual returns (string)
```

### \_generateBackgroundColor

```solidity
function _generateBackgroundColor() internal pure returns (string)
```

### \_generateBackground

```solidity
function _generateBackground() internal pure virtual returns (string)
```

### \_generateHeader

```solidity
function _generateHeader(struct HypercertSVG.SVGParams params) internal pure virtual returns (string)
```

### \_generateName

```solidity
function _generateName(struct HypercertSVG.SVGParams params) internal view virtual returns (string)
```

### \_generateDescription

```solidity
function _generateDescription(struct HypercertSVG.SVGParams params) internal pure virtual returns (string)
```

### \_generateFraction

```solidity
function _generateFraction(struct HypercertSVG.SVGParams params) internal pure virtual returns (string)
```

### \_generateTotalUnits

```solidity
function _generateTotalUnits(struct HypercertSVG.SVGParams params) internal pure virtual returns (string)
```

### \_generateFooter

```solidity
function _generateFooter(struct HypercertSVG.SVGParams params) internal pure virtual returns (string)
```

## IERC3525MetadataUpgradeable

_Interfaces for any contract that wants to support query of the Uniform Resource Identifier
(URI) for the ERC3525 contract as well as a specified slot.
Because of the higher reliability of data stored in smart contracts compared to data stored in
centralized systems, it is recommended that metadata, including `contractURI`, `slotURI` and
`tokenURI`, be directly returned in JSON format, instead of being returned with a url pointing
to any resource stored in a centralized system.
See https://eips.ethereum.org/EIPS/eip-3525
Note: the ERC-165 identifier for this interface is 0xe1600902._

### contractURI

```solidity
function contractURI() external view returns (string)
```

Returns the Uniform Resource Identifier (URI) for the current ERC3525 contract.

_This function SHOULD return the URI for this contract in JSON format, starting with
header `data:application/json;`.
See https://eips.ethereum.org/EIPS/eip-3525 for the JSON schema for contract URI._

| Name | Type   | Description                                            |
| ---- | ------ | ------------------------------------------------------ |
| [0]  | string | The JSON formatted URI of the current ERC3525 contract |

### slotURI

```solidity
function slotURI(uint256 _slot) external view returns (string)
```

Returns the Uniform Resource Identifier (URI) for the specified slot.

_This function SHOULD return the URI for `_slot` in JSON format, starting with header
`data:application/json;`.
See https://eips.ethereum.org/EIPS/eip-3525 for the JSON schema for slot URI._

| Name | Type   | Description                       |
| ---- | ------ | --------------------------------- |
| [0]  | string | The JSON formatted URI of `_slot` |

## IERC3525Receiver

_Interface for any contract that wants to be informed by EIP-3525 contracts when receiving values from other
addresses.
Note: the EIP-165 identifier for this interface is 0x009ce20b._

### onERC3525Received

```solidity
function onERC3525Received(address _operator, uint256 _fromTokenId, uint256 _toTokenId, uint256 _value, bytes _data) external returns (bytes4)
```

Handle the receipt of an EIP-3525 token value.

_An EIP-3525 smart contract MUST check whether this function is implemented by the recipient contract, if the
recipient contract implements this function, the EIP-3525 contract MUST call this function after a
value transfer (i.e. `transferFrom(uint256,uint256,uint256,bytes)`).
MUST return 0x009ce20b (i.e. `bytes4(keccak256('onERC3525Received(address,uint256,uint256, uint256,bytes)'))`) if the transfer is accepted.
MUST revert or return any value other than 0x009ce20b if the transfer is rejected.
The EIP-3525 smart contract that calls this function MUST revert the transfer transaction if the return value
is not equal to 0x009ce20b._

| Name          | Type    | Description                              |
| ------------- | ------- | ---------------------------------------- |
| \_operator    | address | The address which triggered the transfer |
| \_fromTokenId | uint256 | The token id to transfer value from      |
| \_toTokenId   | uint256 | The token id to transfer value to        |
| \_value       | uint256 | The transferred value                    |
| \_data        | bytes   | Additional data with no specified format |

| Name | Type   | Description                                                                                                      |
| ---- | ------ | ---------------------------------------------------------------------------------------------------------------- |
| [0]  | bytes4 | `bytes4(keccak256('onERC3525Received(address,uint256,uint256,uint256,bytes)'))` unless the transfer is rejected. |

## IERC3525SlotApprovableUpgradeable

_Interfaces for any contract that wants to support approval of slot level, which allows an
operator to manage one's tokens with the same slot.
See https://eips.ethereum.org/EIPS/eip-3525
Note: the EIP-165 identifier for this interface is 0xb688be58._

### ApprovalForSlot

```solidity
event ApprovalForSlot(address _owner, uint256 _slot, address _operator, bool _approved)
```

_MUST emit when an operator is approved or disapproved to manage all of `_owner`'s
tokens with the same slot._

| Name       | Type    | Description                                                               |
| ---------- | ------- | ------------------------------------------------------------------------- |
| \_owner    | address | The address whose tokens are approved                                     |
| \_slot     | uint256 | The slot to approve, all of `_owner`'s tokens with this slot are approved |
| \_operator | address | The operator being approved or disapproved                                |
| \_approved | bool    | Identify if `_operator` is approved or disapproved                        |

### setApprovalForSlot

```solidity
function setApprovalForSlot(address _owner, uint256 _slot, address _operator, bool _approved) external payable
```

Approve or disapprove an operator to manage all of `_owner`'s tokens with the
specified slot.

_Caller SHOULD be `_owner` or an operator who has been authorized through
`setApprovalForAll`.
MUST emit ApprovalSlot event._

| Name       | Type    | Description                                              |
| ---------- | ------- | -------------------------------------------------------- |
| \_owner    | address | The address that owns the EIP-3525 tokens                |
| \_slot     | uint256 | The slot of tokens being queried approval of             |
| \_operator | address | The address for whom to query approval                   |
| \_approved | bool    | Identify if `_operator` would be approved or disapproved |

### isApprovedForSlot

```solidity
function isApprovedForSlot(address _owner, uint256 _slot, address _operator) external view returns (bool)
```

Query if `_operator` is authorized to manage all of `_owner`'s tokens with the
specified slot.

| Name       | Type    | Description                                  |
| ---------- | ------- | -------------------------------------------- |
| \_owner    | address | The address that owns the EIP-3525 tokens    |
| \_slot     | uint256 | The slot of tokens being queried approval of |
| \_operator | address | The address for whom to query approval       |

| Name | Type | Description                                                                                         |
| ---- | ---- | --------------------------------------------------------------------------------------------------- |
| [0]  | bool | True if `_operator` is authorized to manage all of `_owner`'s tokens with `_slot`, false otherwise. |

## IERC3525SlotEnumerableUpgradeable

_Interfaces for any contract that wants to support enumeration of slots as well as tokens
with the same slot.
Note: the EIP-165 identifier for this interface is 0x3b741b9e._

### slotCount

```solidity
function slotCount() external view returns (uint256)
```

Get the total amount of slots stored by the contract.

| Name | Type    | Description               |
| ---- | ------- | ------------------------- |
| [0]  | uint256 | The total amount of slots |

### slotByIndex

```solidity
function slotByIndex(uint256 _index) external view returns (uint256)
```

Get the slot at the specified index of all slots stored by the contract.

| Name    | Type    | Description                |
| ------- | ------- | -------------------------- |
| \_index | uint256 | The index in the slot list |

| Name | Type    | Description                       |
| ---- | ------- | --------------------------------- |
| [0]  | uint256 | The slot at `index` of all slots. |

### tokenSupplyInSlot

```solidity
function tokenSupplyInSlot(uint256 _slot) external view returns (uint256)
```

Get the total amount of tokens with the same slot.

| Name   | Type    | Description                        |
| ------ | ------- | ---------------------------------- |
| \_slot | uint256 | The slot to query token supply for |

| Name | Type    | Description                                           |
| ---- | ------- | ----------------------------------------------------- |
| [0]  | uint256 | The total amount of tokens with the specified `_slot` |

### tokenInSlotByIndex

```solidity
function tokenInSlotByIndex(uint256 _slot, uint256 _index) external view returns (uint256)
```

Get the token at the specified index of all tokens with the same slot.

| Name    | Type    | Description                             |
| ------- | ------- | --------------------------------------- |
| \_slot  | uint256 | The slot to query tokens with           |
| \_index | uint256 | The index in the token list of the slot |

| Name | Type    | Description                                         |
| ---- | ------- | --------------------------------------------------- |
| [0]  | uint256 | The token ID at `_index` of all tokens with `_slot` |

## IERC3525Upgradeable

_See https://eips.ethereum.org/EIPS/eip-3525_

### TransferValue

```solidity
event TransferValue(uint256 _fromTokenId, uint256 _toTokenId, uint256 _value)
```

_MUST emit when value of a token is transferred to another token with the same slot,
including zero value transfers (\_value == 0) as well as transfers when tokens are created
(`_fromTokenId` == 0) or destroyed (`_toTokenId` == 0)._

| Name          | Type    | Description                         |
| ------------- | ------- | ----------------------------------- |
| \_fromTokenId | uint256 | The token id to transfer value from |
| \_toTokenId   | uint256 | The token id to transfer value to   |
| \_value       | uint256 | The transferred value               |

### ApprovalValue

```solidity
event ApprovalValue(uint256 _tokenId, address _operator, uint256 _value)
```

_MUST emit when the approval value of a token is set or changed._

| Name       | Type    | Description                                             |
| ---------- | ------- | ------------------------------------------------------- |
| \_tokenId  | uint256 | The token to approve                                    |
| \_operator | address | The operator to approve for                             |
| \_value    | uint256 | The maximum value that `_operator` is allowed to manage |

### SlotChanged

```solidity
event SlotChanged(uint256 _tokenId, uint256 _oldSlot, uint256 _newSlot)
```

_MUST emit when the slot of a token is set or changed._

| Name      | Type    | Description                               |
| --------- | ------- | ----------------------------------------- |
| \_tokenId | uint256 | The token of which slot is set or changed |
| \_oldSlot | uint256 | The previous slot of the token            |
| \_newSlot | uint256 | The updated slot of the token             |

### valueDecimals

```solidity
function valueDecimals() external view returns (uint8)
```

Get the number of decimals the token uses for value - e.g. 6, means the user
representation of the value of a token can be calculated by dividing it by 1,000,000.
Considering the compatibility with third-party wallets, this function is defined as
`valueDecimals()` instead of `decimals()` to avoid conflict with EIP-20 tokens.

| Name | Type  | Description                      |
| ---- | ----- | -------------------------------- |
| [0]  | uint8 | The number of decimals for value |

### balanceOf

```solidity
function balanceOf(uint256 _tokenId) external view returns (uint256)
```

Get the value of a token.

| Name      | Type    | Description                              |
| --------- | ------- | ---------------------------------------- |
| \_tokenId | uint256 | The token for which to query the balance |

| Name | Type    | Description             |
| ---- | ------- | ----------------------- |
| [0]  | uint256 | The value of `_tokenId` |

### slotOf

```solidity
function slotOf(uint256 _tokenId) external view returns (uint256)
```

Get the slot of a token.

| Name      | Type    | Description                |
| --------- | ------- | -------------------------- |
| \_tokenId | uint256 | The identifier for a token |

| Name | Type    | Description           |
| ---- | ------- | --------------------- |
| [0]  | uint256 | The slot of the token |

### approve

```solidity
function approve(uint256 _tokenId, address _operator, uint256 _value) external payable
```

Allow an operator to manage the value of a token, up to the `_value`.

_MUST revert unless caller is the current owner, an authorized operator, or the approved
address for `_tokenId`.
MUST emit the ApprovalValue event._

| Name       | Type    | Description                                                             |
| ---------- | ------- | ----------------------------------------------------------------------- |
| \_tokenId  | uint256 | The token to approve                                                    |
| \_operator | address | The operator to be approved                                             |
| \_value    | uint256 | The maximum value of `_toTokenId` that `_operator` is allowed to manage |

### allowance

```solidity
function allowance(uint256 _tokenId, address _operator) external view returns (uint256)
```

Get the maximum value of a token that an operator is allowed to manage.

| Name       | Type    | Description                                |
| ---------- | ------- | ------------------------------------------ |
| \_tokenId  | uint256 | The token for which to query the allowance |
| \_operator | address | The address of an operator                 |

| Name | Type    | Description                                                                    |
| ---- | ------- | ------------------------------------------------------------------------------ |
| [0]  | uint256 | The current approval value of `_tokenId` that `_operator` is allowed to manage |

### transferFrom

```solidity
function transferFrom(uint256 _fromTokenId, uint256 _toTokenId, uint256 _value) external payable
```

Transfer value from a specified token to another specified token with the same slot.

_Caller MUST be the current owner, an authorized operator or an operator who has been
approved the whole `_fromTokenId` or part of it.
MUST revert if `_fromTokenId` or `_toTokenId` is zero token id or does not exist.
MUST revert if slots of `_fromTokenId` and `_toTokenId` do not match.
MUST revert if `_value` exceeds the balance of `_fromTokenId` or its allowance to the
operator.
MUST emit `TransferValue` event._

| Name          | Type    | Description                      |
| ------------- | ------- | -------------------------------- |
| \_fromTokenId | uint256 | The token to transfer value from |
| \_toTokenId   | uint256 | The token to transfer value to   |
| \_value       | uint256 | The transferred value            |

### transferFrom

```solidity
function transferFrom(uint256 _fromTokenId, address _to, uint256 _value) external payable returns (uint256)
```

Transfer value from a specified token to an address. The caller should confirm that
`_to` is capable of receiving EIP-3525 tokens.

_This function MUST create a new EIP-3525 token with the same slot for `_to`,
or find an existing token with the same slot owned by `_to`, to receive the transferred value.
MUST revert if `_fromTokenId` is zero token id or does not exist.
MUST revert if `_to` is zero address.
MUST revert if `_value` exceeds the balance of `_fromTokenId` or its allowance to the
operator.
MUST emit `Transfer` and `TransferValue` events._

| Name          | Type    | Description                      |
| ------------- | ------- | -------------------------------- |
| \_fromTokenId | uint256 | The token to transfer value from |
| \_to          | address | The address to transfer value to |
| \_value       | uint256 | The transferred value            |

| Name | Type    | Description                                          |
| ---- | ------- | ---------------------------------------------------- |
| [0]  | uint256 | ID of the token which receives the transferred value |

## IHypercertMetadata

### generateSlotURI

```solidity
function generateSlotURI(uint256 slotId) external view returns (string)
```

### generateTokenURI

```solidity
function generateTokenURI(uint256 slotId, uint256 tokenId) external view returns (string)
```

## DateTime

### SECONDS_PER_DAY

```solidity
uint256 SECONDS_PER_DAY
```

### SECONDS_PER_HOUR

```solidity
uint256 SECONDS_PER_HOUR
```

### SECONDS_PER_MINUTE

```solidity
uint256 SECONDS_PER_MINUTE
```

### OFFSET19700101

```solidity
int256 OFFSET19700101
```

### DOW_MON

```solidity
uint256 DOW_MON
```

### DOW_TUE

```solidity
uint256 DOW_TUE
```

### DOW_WED

```solidity
uint256 DOW_WED
```

### DOW_THU

```solidity
uint256 DOW_THU
```

### DOW_FRI

```solidity
uint256 DOW_FRI
```

### DOW_SAT

```solidity
uint256 DOW_SAT
```

### DOW_SUN

```solidity
uint256 DOW_SUN
```

### \_daysFromDate

```solidity
function _daysFromDate(uint256 year, uint256 month, uint256 day) internal pure returns (uint256 _days)
```

### \_daysToDate

```solidity
function _daysToDate(uint256 _days) internal pure returns (uint256 year, uint256 month, uint256 day)
```

### timestampFromDate

```solidity
function timestampFromDate(uint256 year, uint256 month, uint256 day) internal pure returns (uint256 timestamp)
```

### timestampFromDateTime

```solidity
function timestampFromDateTime(uint256 year, uint256 month, uint256 day, uint256 hour, uint256 minute, uint256 second) internal pure returns (uint256 timestamp)
```

### timestampToDate

```solidity
function timestampToDate(uint256 timestamp) internal pure returns (uint256 year, uint256 month, uint256 day)
```

### timestampToDateTime

```solidity
function timestampToDateTime(uint256 timestamp) internal pure returns (uint256 year, uint256 month, uint256 day, uint256 hour, uint256 minute, uint256 second)
```

### isValidDate

```solidity
function isValidDate(uint256 year, uint256 month, uint256 day) internal pure returns (bool valid)
```

### isValidDateTime

```solidity
function isValidDateTime(uint256 year, uint256 month, uint256 day, uint256 hour, uint256 minute, uint256 second) internal pure returns (bool valid)
```

### isLeapYear

```solidity
function isLeapYear(uint256 timestamp) internal pure returns (bool leapYear)
```

### \_isLeapYear

```solidity
function _isLeapYear(uint256 year) internal pure returns (bool leapYear)
```

### isWeekDay

```solidity
function isWeekDay(uint256 timestamp) internal pure returns (bool weekDay)
```

### isWeekEnd

```solidity
function isWeekEnd(uint256 timestamp) internal pure returns (bool weekEnd)
```

### getDaysInMonth

```solidity
function getDaysInMonth(uint256 timestamp) internal pure returns (uint256 daysInMonth)
```

### \_getDaysInMonth

```solidity
function _getDaysInMonth(uint256 year, uint256 month) internal pure returns (uint256 daysInMonth)
```

### getDayOfWeek

```solidity
function getDayOfWeek(uint256 timestamp) internal pure returns (uint256 dayOfWeek)
```

### getYear

```solidity
function getYear(uint256 timestamp) internal pure returns (uint256 year)
```

### getMonth

```solidity
function getMonth(uint256 timestamp) internal pure returns (uint256 month)
```

### getDay

```solidity
function getDay(uint256 timestamp) internal pure returns (uint256 day)
```

### getHour

```solidity
function getHour(uint256 timestamp) internal pure returns (uint256 hour)
```

### getMinute

```solidity
function getMinute(uint256 timestamp) internal pure returns (uint256 minute)
```

### getSecond

```solidity
function getSecond(uint256 timestamp) internal pure returns (uint256 second)
```

### addYears

```solidity
function addYears(uint256 timestamp, uint256 _years) internal pure returns (uint256 newTimestamp)
```

### addMonths

```solidity
function addMonths(uint256 timestamp, uint256 _months) internal pure returns (uint256 newTimestamp)
```

### addDays

```solidity
function addDays(uint256 timestamp, uint256 _days) internal pure returns (uint256 newTimestamp)
```

### addHours

```solidity
function addHours(uint256 timestamp, uint256 _hours) internal pure returns (uint256 newTimestamp)
```

### addMinutes

```solidity
function addMinutes(uint256 timestamp, uint256 _minutes) internal pure returns (uint256 newTimestamp)
```

### addSeconds

```solidity
function addSeconds(uint256 timestamp, uint256 _seconds) internal pure returns (uint256 newTimestamp)
```

### subYears

```solidity
function subYears(uint256 timestamp, uint256 _years) internal pure returns (uint256 newTimestamp)
```

### subMonths

```solidity
function subMonths(uint256 timestamp, uint256 _months) internal pure returns (uint256 newTimestamp)
```

### subDays

```solidity
function subDays(uint256 timestamp, uint256 _days) internal pure returns (uint256 newTimestamp)
```

### subHours

```solidity
function subHours(uint256 timestamp, uint256 _hours) internal pure returns (uint256 newTimestamp)
```

### subMinutes

```solidity
function subMinutes(uint256 timestamp, uint256 _minutes) internal pure returns (uint256 newTimestamp)
```

### subSeconds

```solidity
function subSeconds(uint256 timestamp, uint256 _seconds) internal pure returns (uint256 newTimestamp)
```

### diffYears

```solidity
function diffYears(uint256 fromTimestamp, uint256 toTimestamp) internal pure returns (uint256 _years)
```

### diffMonths

```solidity
function diffMonths(uint256 fromTimestamp, uint256 toTimestamp) internal pure returns (uint256 _months)
```

### diffDays

```solidity
function diffDays(uint256 fromTimestamp, uint256 toTimestamp) internal pure returns (uint256 _days)
```

### diffHours

```solidity
function diffHours(uint256 fromTimestamp, uint256 toTimestamp) internal pure returns (uint256 _hours)
```

### diffMinutes

```solidity
function diffMinutes(uint256 fromTimestamp, uint256 toTimestamp) internal pure returns (uint256 _minutes)
```

### diffSeconds

```solidity
function diffSeconds(uint256 fromTimestamp, uint256 toTimestamp) internal pure returns (uint256 _seconds)
```

## strings

### slice

```solidity
struct slice {
  uint256 _len;
  uint256 _ptr;
}

```

### memcpy

```solidity
function memcpy(uint256 dest, uint256 src, uint256 len) private pure
```

### toSlice

```solidity
function toSlice(string self) internal pure returns (struct strings.slice)
```

### len

```solidity
function len(bytes32 self) internal pure returns (uint256)
```

### toSliceB32

```solidity
function toSliceB32(bytes32 self) internal pure returns (struct strings.slice ret)
```

### copy

```solidity
function copy(struct strings.slice self) internal pure returns (struct strings.slice)
```

### toString

```solidity
function toString(struct strings.slice self) internal pure returns (string)
```

### len

```solidity
function len(struct strings.slice self) internal pure returns (uint256 l)
```

### empty

```solidity
function empty(struct strings.slice self) internal pure returns (bool)
```

### compare

```solidity
function compare(struct strings.slice self, struct strings.slice other) internal pure returns (int256)
```

### equals

```solidity
function equals(struct strings.slice self, struct strings.slice other) internal pure returns (bool)
```

### nextRune

```solidity
function nextRune(struct strings.slice self, struct strings.slice rune) internal pure returns (struct strings.slice)
```

### nextRune

```solidity
function nextRune(struct strings.slice self) internal pure returns (struct strings.slice ret)
```

### ord

```solidity
function ord(struct strings.slice self) internal pure returns (uint256 ret)
```

### keccak

```solidity
function keccak(struct strings.slice self) internal pure returns (bytes32 ret)
```

### startsWith

```solidity
function startsWith(struct strings.slice self, struct strings.slice needle) internal pure returns (bool)
```

### beyond

```solidity
function beyond(struct strings.slice self, struct strings.slice needle) internal pure returns (struct strings.slice)
```

### endsWith

```solidity
function endsWith(struct strings.slice self, struct strings.slice needle) internal pure returns (bool)
```

### until

```solidity
function until(struct strings.slice self, struct strings.slice needle) internal pure returns (struct strings.slice)
```

### findPtr

```solidity
function findPtr(uint256 selflen, uint256 selfptr, uint256 needlelen, uint256 needleptr) private pure returns (uint256)
```

### rfindPtr

```solidity
function rfindPtr(uint256 selflen, uint256 selfptr, uint256 needlelen, uint256 needleptr) private pure returns (uint256)
```

### find

```solidity
function find(struct strings.slice self, struct strings.slice needle) internal pure returns (struct strings.slice)
```

### rfind

```solidity
function rfind(struct strings.slice self, struct strings.slice needle) internal pure returns (struct strings.slice)
```

### split

```solidity
function split(struct strings.slice self, struct strings.slice needle, struct strings.slice token) internal pure returns (struct strings.slice)
```

### split

```solidity
function split(struct strings.slice self, struct strings.slice needle) internal pure returns (struct strings.slice token)
```

### rsplit

```solidity
function rsplit(struct strings.slice self, struct strings.slice needle, struct strings.slice token) internal pure returns (struct strings.slice)
```

### rsplit

```solidity
function rsplit(struct strings.slice self, struct strings.slice needle) internal pure returns (struct strings.slice token)
```

### count

```solidity
function count(struct strings.slice self, struct strings.slice needle) internal pure returns (uint256 cnt)
```

### contains

```solidity
function contains(struct strings.slice self, struct strings.slice needle) internal pure returns (bool)
```

### concat

```solidity
function concat(struct strings.slice self, struct strings.slice other) internal pure returns (string)
```

### join

```solidity
function join(struct strings.slice self, struct strings.slice[] parts) internal pure returns (string)
```

## ArraysUpgradeable

_Collection of functions related to array types._

### getSum

```solidity
function getSum(uint8[] array) internal pure returns (uint256)
```

_calculate the sum of the elements of an array_

### toString

```solidity
function toString(uint64[2] array) internal pure returns (string)
```

### toCsv

```solidity
function toCsv(uint256[] array) internal pure returns (string)
```

### toCsv

```solidity
function toCsv(string[] array) internal pure returns (string)
```

## StringsExtensions

_Collection of functions related to array types._

### toString

```solidity
function toString(bool value) internal pure returns (string)
```

_returns either "true" or "false"_
