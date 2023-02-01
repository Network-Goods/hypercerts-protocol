Summary

- [solc-version](#solc-version) (4 results) (Informational)
- [naming-convention](#naming-convention) (17 results) (Informational)
- [uninitialized-local](#uninitialized-local) (12 results) (Medium)
- [shadowing-local](#shadowing-local) (2 results) (Low)
- [dead-code](#dead-code) (23 results) (Informational)
- [unused-state](#unused-state) (2 results) (Informational)

## solc-version

Impact: Informational Confidence: High

- [ ] ID-0 solc-0.8.17 is not recommended for deployment

- [ ] ID-1 solc-0.8.17 is not recommended for deployment

- [ ] ID-2 solc-0.8.17 is not recommended for deployment

- [ ] ID-3 solc-0.8.17 is not recommended for deployment

## naming-convention

Impact: Informational Confidence: High

- [ ] ID-4 Function [Upgradeable1155.\_\_Upgradeable1155_init()](src/Upgradeable1155.sol#L21-L27) is not in mixedCase

src/Upgradeable1155.sol#L21-L27

- [ ] ID-5 Parameter [HypercertMinter.splitValue(address,uint256,uint256[]).\_values](src/HypercertMinter.sol#L102) is
      not in mixedCase

src/HypercertMinter.sol#L102

- [ ] ID-6 Function [Upgradeable1155.\_\_Upgradeable1155_init()](src/Upgradeable1155.sol#L21-L27) is not in mixedCase

src/Upgradeable1155.sol#L21-L27

- [ ] ID-7 Function [SemiFungible1155.\_\_SemiFungible1155_init()](src/SemiFungible1155.sol#L45-L47) is not in mixedCase

src/SemiFungible1155.sol#L45-L47

- [ ] ID-8 Variable [HypercertMinter.\_\_gap](src/HypercertMinter.sol#L184) is not in mixedCase

src/HypercertMinter.sol#L184

- [ ] ID-9 Parameter [HypercertMinter.mergeValue(uint256[]).\_fractionIDs](src/HypercertMinter.sol#L108) is not in
      mixedCase

src/HypercertMinter.sol#L108

- [ ] ID-10 Parameter [HypercertMinter.splitValue(address,uint256,uint256[]).\_tokenID](src/HypercertMinter.sol#L102) is
      not in mixedCase

src/HypercertMinter.sol#L102

- [ ] ID-11 Parameter [HypercertMinter.burnValue(address,uint256).\_tokenID](src/HypercertMinter.sol#L114) is not in
      mixedCase

src/HypercertMinter.sol#L114

- [ ] ID-12 Parameter [HypercertMinter.splitValue(address,uint256,uint256[]).\_account](src/HypercertMinter.sol#L102) is
      not in mixedCase

src/HypercertMinter.sol#L102

- [ ] ID-13 Parameter
      [HypercertMinter.mintClaimWithFractions(uint256,uint256[],string,IHypercertToken.TransferRestrictions).\_uri](src/HypercertMinter.sol#L51)
      is not in mixedCase

src/HypercertMinter.sol#L51

- [ ] ID-14 Parameter
      [HypercertMinter.mintClaim(uint256,string,IHypercertToken.TransferRestrictions).\_uri](src/HypercertMinter.sol#L40)
      is not in mixedCase

src/HypercertMinter.sol#L40

- [ ] ID-15 Variable [SemiFungible1155.\_\_gap](src/SemiFungible1155.sol#L375) is not in mixedCase

src/SemiFungible1155.sol#L375

- [ ] ID-16 Parameter
      [HypercertMinter.createAllowlist(uint256,bytes32,string,IHypercertToken.TransferRestrictions).\_uri](src/HypercertMinter.sol#L91)
      is not in mixedCase

src/HypercertMinter.sol#L91

- [ ] ID-17 Parameter [HypercertMinter.burnValue(address,uint256).\_account](src/HypercertMinter.sol#L114) is not in
      mixedCase

src/HypercertMinter.sol#L114

- [ ] ID-18 Function [Upgradeable1155.\_\_Upgradeable1155_init()](src/Upgradeable1155.sol#L21-L27) is not in mixedCase

src/Upgradeable1155.sol#L21-L27

- [ ] ID-19 Function [SemiFungible1155.\_\_SemiFungible1155_init()](src/SemiFungible1155.sol#L45-L47) is not in
      mixedCase

src/SemiFungible1155.sol#L45-L47

- [ ] ID-20 Variable [SemiFungible1155.\_\_gap](src/SemiFungible1155.sol#L375) is not in mixedCase

src/SemiFungible1155.sol#L375

## uninitialized-local

Impact: Medium Confidence: Medium

- [ ] ID-21 [SemiFungible1155.\_getSum(uint256[]).i](src/SemiFungible1155.sol#L353) is a local variable never
      initialized

src/SemiFungible1155.sol#L353

- [ ] ID-22 [SemiFungible1155.\_batchMintClaims(uint256[],uint256[]).i](src/SemiFungible1155.sol#L161) is a local
      variable never initialized

src/SemiFungible1155.sol#L161

- [ ] ID-23
      [SemiFungible1155.\_beforeTokenTransfer(address,address,address,uint256[],uint256[],bytes).i](src/SemiFungible1155.sol#L288)
      is a local variable never initialized

src/SemiFungible1155.sol#L288

- [ ] ID-24
      [HypercertMinter.\_beforeTokenTransfer(address,address,address,uint256[],uint256[],bytes).i](src/HypercertMinter.sol#L162)
      is a local variable never initialized

src/HypercertMinter.sol#L162

- [ ] ID-25 [SemiFungible1155.\_mergeValue(uint256[]).i](src/SemiFungible1155.sol#L241) is a local variable never
      initialized

src/SemiFungible1155.sol#L241

- [ ] ID-26
      [HypercertMinter.batchMintClaimsFromAllowlists(bytes32[][],uint256[],uint256[]).i](src/HypercertMinter.sol#L76) is
      a local variable never initialized

src/HypercertMinter.sol#L76

- [ ] ID-27
      [SemiFungible1155.\_afterTokenTransfer(address,address,address,uint256[],uint256[],bytes).i](src/SemiFungible1155.sol#L310)
      is a local variable never initialized

src/SemiFungible1155.sol#L310

- [ ] ID-28 [SemiFungible1155.\_getSum(uint256[]).i](src/SemiFungible1155.sol#L353) is a local variable never
      initialized

src/SemiFungible1155.sol#L353

- [ ] ID-29 [SemiFungible1155.\_batchMintClaims(uint256[],uint256[]).i](src/SemiFungible1155.sol#L161) is a local
      variable never initialized

src/SemiFungible1155.sol#L161

- [ ] ID-30
      [SemiFungible1155.\_beforeTokenTransfer(address,address,address,uint256[],uint256[],bytes).i](src/SemiFungible1155.sol#L288)
      is a local variable never initialized

src/SemiFungible1155.sol#L288

- [ ] ID-31 [SemiFungible1155.\_mergeValue(uint256[]).i](src/SemiFungible1155.sol#L241) is a local variable never
      initialized

src/SemiFungible1155.sol#L241

- [ ] ID-32
      [SemiFungible1155.\_afterTokenTransfer(address,address,address,uint256[],uint256[],bytes).i](src/SemiFungible1155.sol#L310)
      is a local variable never initialized

src/SemiFungible1155.sol#L310

## shadowing-local

Impact: Low Confidence: High

- [ ] ID-33
      [IHypercertToken.mintClaimWithFractions(uint256,uint256[],string,IHypercertToken.TransferRestrictions).uri](src/interfaces/IHypercertToken.sol#L32)
      shadows: - [IHypercertToken.uri(uint256)](src/interfaces/IHypercertToken.sol#L62) (function)

src/interfaces/IHypercertToken.sol#L32

- [ ] ID-34
      [IHypercertToken.mintClaim(uint256,string,IHypercertToken.TransferRestrictions).uri](src/interfaces/IHypercertToken.sol#L25)
      shadows: - [IHypercertToken.uri(uint256)](src/interfaces/IHypercertToken.sol#L62) (function)

src/interfaces/IHypercertToken.sol#L25

## dead-code

Impact: Informational Confidence: Medium

- [ ] ID-35 [SemiFungible1155.isTypedItem(uint256)](src/SemiFungible1155.sol#L68-L70) is never used and should be
      removed

src/SemiFungible1155.sol#L68-L70

- [ ] ID-36 [SemiFungible1155.\_authorizeUpgrade(address)](src/SemiFungible1155.sol#L318-L320) is never used and should
      be removed

src/SemiFungible1155.sol#L318-L320

- [ ] ID-37 [Upgradeable1155.\_authorizeUpgrade(address)](src/Upgradeable1155.sol#L30-L32) is never used and should be
      removed

src/Upgradeable1155.sol#L30-L32

- [ ] ID-38 [SemiFungible1155.getItemIndex(uint256)](src/SemiFungible1155.sol#L51-L53) is never used and should be
      removed

src/SemiFungible1155.sol#L51-L53

- [ ] ID-39 [SemiFungible1155.\_getSum(uint256[])](src/SemiFungible1155.sol#L351-L360) is never used and should be
      removed

src/SemiFungible1155.sol#L351-L360

- [ ] ID-40 [SemiFungible1155.\_notMaxItem(uint256)](src/SemiFungible1155.sol#L335-L338) is never used and should be
      removed

src/SemiFungible1155.sol#L335-L338

- [ ] ID-41 [SemiFungible1155.\_notMaxType(uint256)](src/SemiFungible1155.sol#L343-L346) is never used and should be
      removed

src/SemiFungible1155.sol#L343-L346

- [ ] ID-42 [SemiFungible1155.\_burnValue(address,uint256)](src/SemiFungible1155.sol#L263-L273) is never used and should
      be removed

src/SemiFungible1155.sol#L263-L273

- [ ] ID-43 [SemiFungible1155.isTypedItem(uint256)](src/SemiFungible1155.sol#L68-L70) is never used and should be
      removed

src/SemiFungible1155.sol#L68-L70

- [ ] ID-44 [SemiFungible1155.\_mergeValue(uint256[])](src/SemiFungible1155.sol#L228-L258) is never used and should be
      removed

src/SemiFungible1155.sol#L228-L258

- [ ] ID-45 [SemiFungible1155.\_mintValue(address,uint256,string)](src/SemiFungible1155.sol#L106-L118) is never used and
      should be removed

src/SemiFungible1155.sol#L106-L118

- [ ] ID-46 [Upgradeable1155.\_authorizeUpgrade(address)](src/Upgradeable1155.sol#L30-L32) is never used and should be
      removed

src/Upgradeable1155.sol#L30-L32

- [ ] ID-47 [SemiFungible1155.\_mintValue(address,uint256[],string)](src/SemiFungible1155.sol#L121-L134) is never used
      and should be removed

src/SemiFungible1155.sol#L121-L134

- [ ] ID-48 [SemiFungible1155.\_unitsOf(uint256)](src/SemiFungible1155.sol#L78-L80) is never used and should be removed

src/SemiFungible1155.sol#L78-L80

- [ ] ID-49 [SemiFungible1155.\_mintClaim(uint256,uint256)](src/SemiFungible1155.sol#L137-L149) is never used and should
      be removed

src/SemiFungible1155.sol#L137-L149

- [ ] ID-50 [SemiFungible1155.getItemIndex(uint256)](src/SemiFungible1155.sol#L51-L53) is never used and should be
      removed

src/SemiFungible1155.sol#L51-L53

- [ ] ID-51 [SemiFungible1155.\_batchMintClaims(uint256[],uint256[])](src/SemiFungible1155.sol#L153-L182) is never used
      and should be removed

src/SemiFungible1155.sol#L153-L182

- [ ] ID-52 [SemiFungible1155.\_splitValue(address,uint256,uint256[])](src/SemiFungible1155.sol#L187-L224) is never used
      and should be removed

src/SemiFungible1155.sol#L187-L224

- [ ] ID-53 [SemiFungible1155.\_unitsOf(address,uint256)](src/SemiFungible1155.sol#L83-L88) is never used and should be
      removed

src/SemiFungible1155.sol#L83-L88

- [ ] ID-54 [SemiFungible1155.\_createTokenType(uint256,string)](src/SemiFungible1155.sol#L94-L103) is never used and
      should be removed

src/SemiFungible1155.sol#L94-L103

- [ ] ID-55 [AllowlistMinter.\_calculateLeaf(address,uint256)](src/AllowlistMinter.sol#L49-L51) is never used and should
      be removed

src/AllowlistMinter.sol#L49-L51

- [ ] ID-56 [AllowlistMinter.\_createAllowlist(uint256,bytes32)](src/AllowlistMinter.sol#L29-L34) is never used and
      should be removed

src/AllowlistMinter.sol#L29-L34

- [ ] ID-57 [AllowlistMinter.\_processClaim(bytes32[],uint256,uint256)](src/AllowlistMinter.sol#L36-L47) is never used
      and should be removed

src/AllowlistMinter.sol#L36-L47

## unused-state

Impact: Informational Confidence: High

- [ ] ID-58 [HypercertMinter.\_\_gap](src/HypercertMinter.sol#L184) is never used in
      [HypercertMinter](src/HypercertMinter.sol#L16-L185)

src/HypercertMinter.sol#L184

- [ ] ID-59 [SemiFungible1155.\_\_gap](src/SemiFungible1155.sol#L375) is never used in
      [SemiFungible1155](src/SemiFungible1155.sol#L15-L376)

src/SemiFungible1155.sol#L375
