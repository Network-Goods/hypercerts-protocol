# IHypercertToken

*bitbeckers*

> Interface for hypercert token interactions

This interface declares the required functionality for a hypercert tokenThis interface does not specify the underlying token type (e.g. 721 or 1155)



## Methods

### burnValue

```solidity
function burnValue(address account, uint256 tokenID) external nonpayable
```

Operator must be allowed by `creator` and the token must represent the total amount of available units.

*Function to burn the token at `tokenID` for `account`*

#### Parameters

| Name | Type | Description |
|---|---|---|
| account | address | undefined |
| tokenID | uint256 | undefined |

### mergeValue

```solidity
function mergeValue(uint256[] tokenIDs) external nonpayable
```

Tokens that have been merged are burned.

*Function called to merge tokens within `tokenIDs`.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenIDs | uint256[] | undefined |

### mintClaim

```solidity
function mintClaim(uint256 units, string uri) external nonpayable
```



*Function called to store a claim referenced via `uri` with a maximum number of fractions `units`.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| units | uint256 | undefined |
| uri | string | undefined |

### mintClaimWithFractions

```solidity
function mintClaimWithFractions(uint256[] fractions, string uri) external nonpayable
```



*Function called to store a claim referenced via `uri` with a set of `fractions`.Fractions are internally summed to total units.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| fractions | uint256[] | undefined |
| uri | string | undefined |

### splitValue

```solidity
function splitValue(address account, uint256 tokenID, uint256[] _values) external nonpayable
```

The sum of `values` must equal the current value of `_tokenID`.

*Function called to split `tokenID` owned by `account` into units declared in `values`.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| account | address | undefined |
| tokenID | uint256 | undefined |
| _values | uint256[] | undefined |



## Events

### ClaimStored

```solidity
event ClaimStored(uint256 indexed claimID, string uri)
```



*Emitted when token with tokenID `claimID` is stored, with external data reference via `uri`.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| claimID `indexed` | uint256 | undefined |
| uri  | string | undefined |



