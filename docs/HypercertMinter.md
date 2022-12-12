# HypercertMinter

*bitbeckers*

> Contract for managing hypercert claims and whitelists

Implementation of the HypercertTokenInterface using { SemiFungible1155 } as underlying token.This contract supports whitelisted minting via { AllowlistMinter }.

*Wrapper contract to expose and chain functions.*

## Methods

### NF_INDEX_MASK

```solidity
function NF_INDEX_MASK() external view returns (uint256)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### TYPE_MASK

```solidity
function TYPE_MASK() external view returns (uint256)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### TYPE_NF_BIT

```solidity
function TYPE_NF_BIT() external view returns (uint256)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### __SemiFungible1155_init

```solidity
function __SemiFungible1155_init() external nonpayable
```



*Init method. Underlying { Upgradeable1155 } is `Initializable`*


### __Upgradeable1155_init

```solidity
function __Upgradeable1155_init() external nonpayable
```



*see { openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol }*


### balanceOf

```solidity
function balanceOf(address _owner, uint256 _tokenID) external view returns (uint256 tokenUserBalance)
```

READ



#### Parameters

| Name | Type | Description |
|---|---|---|
| _owner | address | undefined |
| _tokenID | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| tokenUserBalance | uint256 | undefined |

### balanceOf

```solidity
function balanceOf(uint256 _tokenID) external view returns (uint256 tokenValue)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _tokenID | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| tokenValue | uint256 | undefined |

### balanceOfBatch

```solidity
function balanceOfBatch(address[] accounts, uint256[] ids) external view returns (uint256[])
```



*See {IERC1155-balanceOfBatch}. Requirements: - `accounts` and `ids` must have the same length.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| accounts | address[] | undefined |
| ids | uint256[] | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256[] | undefined |

### burn

```solidity
function burn(address account, uint256 id, uint256 value) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| account | address | undefined |
| id | uint256 | undefined |
| value | uint256 | undefined |

### burnBatch

```solidity
function burnBatch(address account, uint256[] ids, uint256[] values) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| account | address | undefined |
| ids | uint256[] | undefined |
| values | uint256[] | undefined |

### burnValue

```solidity
function burnValue(address _account, uint256 _tokenID) external nonpayable
```

Burn a claimtoken

*see {IHypercertToken}*

#### Parameters

| Name | Type | Description |
|---|---|---|
| _account | address | undefined |
| _tokenID | uint256 | undefined |

### createAllowlist

```solidity
function createAllowlist(uint256 units, bytes32 merkleRoot, string uri) external nonpayable
```

Register a claim and the whitelist for minting token(s) belonging to that claim

*Calls SemiFungible1155 to store the claim referenced in `uri` with amount of `units`Calls AlloslistMinter to store the `merkleRoot` as proof to authorize claims*

#### Parameters

| Name | Type | Description |
|---|---|---|
| units | uint256 | undefined |
| merkleRoot | bytes32 | undefined |
| uri | string | undefined |

### hasBeenClaimed

```solidity
function hasBeenClaimed(uint256, bytes32) external view returns (bool)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |
| _1 | bytes32 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### initialize

```solidity
function initialize() external nonpayable
```



*see { openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol }*


### isAllowedToClaim

```solidity
function isAllowedToClaim(bytes32[] proof, uint256 claimID, bytes32 leaf) external view returns (bool isAllowed)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| proof | bytes32[] | undefined |
| claimID | uint256 | undefined |
| leaf | bytes32 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| isAllowed | bool | undefined |

### isApprovedForAll

```solidity
function isApprovedForAll(address account, address operator) external view returns (bool)
```



*See {IERC1155-isApprovedForAll}.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| account | address | undefined |
| operator | address | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### mergeValue

```solidity
function mergeValue(uint256[] _fractionIDs) external nonpayable
```

Merge the value of tokens belonging to the same claim

*see {IHypercertToken}*

#### Parameters

| Name | Type | Description |
|---|---|---|
| _fractionIDs | uint256[] | undefined |

### mintClaim

```solidity
function mintClaim(uint256 units, string uri) external nonpayable
```

Mint a semi-fungible token for the impact claim referenced via `uri`

*see {IHypercertToken}*

#### Parameters

| Name | Type | Description |
|---|---|---|
| units | uint256 | undefined |
| uri | string | undefined |

### mintClaimFromAllowlist

```solidity
function mintClaimFromAllowlist(bytes32[] proof, uint256 claimID, uint256 amount) external nonpayable
```

Mint a semi-fungible token representing a fraction of the claim

*Calls AllowlistMinter to verify `proof`.Mints the `amount` of units for the hypercert stored under `claimID`*

#### Parameters

| Name | Type | Description |
|---|---|---|
| proof | bytes32[] | undefined |
| claimID | uint256 | undefined |
| amount | uint256 | undefined |

### mintClaimWithFractions

```solidity
function mintClaimWithFractions(uint256[] fractions, string uri) external nonpayable
```

Mint semi-fungible tokens for the impact claim referenced via `uri`

*see {IHypercertToken}*

#### Parameters

| Name | Type | Description |
|---|---|---|
| fractions | uint256[] | undefined |
| uri | string | undefined |

### name

```solidity
function name() external view returns (string)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | string | undefined |

### owner

```solidity
function owner() external view returns (address)
```



*Returns the address of the current owner.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### proxiableUUID

```solidity
function proxiableUUID() external view returns (bytes32)
```



*Implementation of the ERC1822 {proxiableUUID} function. This returns the storage slot used by the implementation. It is used to validate the implementation&#39;s compatibility when performing an upgrade. IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this function revert if invoked through a proxy. This is guaranteed by the `notDelegated` modifier.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bytes32 | undefined |

### renounceOwnership

```solidity
function renounceOwnership() external nonpayable
```



*Leaves the contract without owner. It will not be possible to call `onlyOwner` functions anymore. Can only be called by the current owner. NOTE: Renouncing ownership will leave the contract without an owner, thereby removing any functionality that is only available to the owner.*


### safeBatchTransferFrom

```solidity
function safeBatchTransferFrom(address from, address to, uint256[] ids, uint256[] amounts, bytes data) external nonpayable
```



*See {IERC1155-safeBatchTransferFrom}.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| from | address | undefined |
| to | address | undefined |
| ids | uint256[] | undefined |
| amounts | uint256[] | undefined |
| data | bytes | undefined |

### safeTransferFrom

```solidity
function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes _data) external nonpayable
```

Transfers



#### Parameters

| Name | Type | Description |
|---|---|---|
| _from | address | undefined |
| _to | address | undefined |
| _id | uint256 | undefined |
| _value | uint256 | undefined |
| _data | bytes | undefined |

### setApprovalForAll

```solidity
function setApprovalForAll(address operator, bool approved) external nonpayable
```



*See {IERC1155-setApprovalForAll}.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| operator | address | undefined |
| approved | bool | undefined |

### splitValue

```solidity
function splitValue(address _account, uint256 _tokenID, uint256[] _values) external nonpayable
```

Split a claimtokens value into parts with summed value equal to the original

*see {IHypercertToken}*

#### Parameters

| Name | Type | Description |
|---|---|---|
| _account | address | undefined |
| _tokenID | uint256 | undefined |
| _values | uint256[] | undefined |

### supportsInterface

```solidity
function supportsInterface(bytes4 interfaceId) external view returns (bool)
```



*See {IERC165-supportsInterface}.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| interfaceId | bytes4 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### totalSupply

```solidity
function totalSupply(uint256 _typeID) external view returns (uint256 total)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _typeID | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| total | uint256 | undefined |

### transferOwnership

```solidity
function transferOwnership(address newOwner) external nonpayable
```



*Transfers ownership of the contract to a new account (`newOwner`). Can only be called by the current owner.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| newOwner | address | undefined |

### typeCounter

```solidity
function typeCounter() external view returns (uint256)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### upgradeTo

```solidity
function upgradeTo(address newImplementation) external nonpayable
```



*Upgrade the implementation of the proxy to `newImplementation`. Calls {_authorizeUpgrade}. Emits an {Upgraded} event.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| newImplementation | address | undefined |

### upgradeToAndCall

```solidity
function upgradeToAndCall(address newImplementation, bytes data) external payable
```



*Upgrade the implementation of the proxy to `newImplementation`, and subsequently execute the function call encoded in `data`. Calls {_authorizeUpgrade}. Emits an {Upgraded} event.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| newImplementation | address | undefined |
| data | bytes | undefined |

### uri

```solidity
function uri(uint256 tokenID) external view returns (string _uri)
```



*see { openzeppelin-contracts-upgradeable/token/ERC1155/extensions/ERC1155URIStorageUpgradeable.sol }*

#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenID | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _uri | string | undefined |



## Events

### AdminChanged

```solidity
event AdminChanged(address previousAdmin, address newAdmin)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| previousAdmin  | address | undefined |
| newAdmin  | address | undefined |

### AllowlistCreated

```solidity
event AllowlistCreated(uint256 tokenID, bytes32 root)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenID  | uint256 | undefined |
| root  | bytes32 | undefined |

### ApprovalForAll

```solidity
event ApprovalForAll(address indexed account, address indexed operator, bool approved)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| account `indexed` | address | undefined |
| operator `indexed` | address | undefined |
| approved  | bool | undefined |

### BeaconUpgraded

```solidity
event BeaconUpgraded(address indexed beacon)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| beacon `indexed` | address | undefined |

### ClaimStored

```solidity
event ClaimStored(uint256 indexed claimID, string uri)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| claimID `indexed` | uint256 | undefined |
| uri  | string | undefined |

### Initialized

```solidity
event Initialized(uint8 version)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| version  | uint8 | undefined |

### LeafClaimed

```solidity
event LeafClaimed(uint256 tokenID, bytes32 leaf)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenID  | uint256 | undefined |
| leaf  | bytes32 | undefined |

### OwnershipTransferred

```solidity
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| previousOwner `indexed` | address | undefined |
| newOwner `indexed` | address | undefined |

### TransferBatch

```solidity
event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| operator `indexed` | address | undefined |
| from `indexed` | address | undefined |
| to `indexed` | address | undefined |
| ids  | uint256[] | undefined |
| values  | uint256[] | undefined |

### TransferSingle

```solidity
event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| operator `indexed` | address | undefined |
| from `indexed` | address | undefined |
| to `indexed` | address | undefined |
| id  | uint256 | undefined |
| value  | uint256 | undefined |

### URI

```solidity
event URI(string value, uint256 indexed id)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| value  | string | undefined |
| id `indexed` | uint256 | undefined |

### Upgraded

```solidity
event Upgraded(address indexed implementation)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| implementation `indexed` | address | undefined |

### ValueTransfer

```solidity
event ValueTransfer(uint256 fromTokenID, uint256 toTokenID, uint256 value)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| fromTokenID  | uint256 | undefined |
| toTokenID  | uint256 | undefined |
| value  | uint256 | undefined |



## Errors

### ArraySize

```solidity
error ArraySize()
```






### DoesNotExist

```solidity
error DoesNotExist()
```






### DuplicateEntry

```solidity
error DuplicateEntry()
```






### FractionalBurn

```solidity
error FractionalBurn()
```






### Invalid

```solidity
error Invalid()
```






### NotAllowed

```solidity
error NotAllowed()
```






### NotApprovedOrOwner

```solidity
error NotApprovedOrOwner()
```






### ToZeroAddress

```solidity
error ToZeroAddress()
```






### TypeMismatch

```solidity
error TypeMismatch()
```







