/*
  in order to adjust the build folder:
    1) import any files here you want in the final build package.
    2) copy the file path of the import.
    3) add the path to the ts.config.build.json under the { include: [...] } configuration.
    4) bump package.json version to publish a new package to npm.
*/

// ABIs
export { default as HyperCertMinterABI } from "../abi/HyperCertMinter.json";
export { default as HyperCertSVGABI } from "../abi/HyperCertSVG.json";
export { default as HyperCertMetadataABI } from "../abi/HyperCertMetadata.json";
export { default as IHyperCertMinterABI } from "../abi/IHyperCertMinter.json";
export { default as IHyperCertSVGABI } from "../abi/IHyperCertSVG.json";
export { default as ERC3525SlotEnumerableUpgradeableABI } from "../abi/ERC3525SlotEnumerableUpgradeable.json";
export { default as ERC3525UpgradeableABI } from "../abi/ERC3525Upgradeable.json";

// Interfaces
export type { IERC3525MetadataUpgradeable } from "./types/contracts/interfaces/IERC3525MetadataUpgradeable";
export type { IERC3525Receiver } from "./types/contracts/interfaces/IERC3525Receiver";
export type { IERC3525SlotApprovableUpgradeable } from "./types/contracts/interfaces/IERC3525SlotApprovableUpgradeable";
export type { IERC3525SlotEnumerableUpgradeable } from "./types/contracts/interfaces/IERC3525SlotEnumerableUpgradeable";
export type { IERC3525Upgradeable } from "./types/contracts/interfaces/IERC3525Upgradeable";
export type { IHyperCertMetadata } from "./types/contracts/interfaces/IHyperCertMetadata";

// Contracts
export { HyperCertMinter } from "./types/contracts/HyperCertMinter";
export { HyperCertSVG } from "./types/contracts/HyperCertSVG";
export { HyperCertMetadata } from "./types/contracts/HyperCertMetadata.sol/HyperCertMetadata";
export { IHyperCertMinter } from "./types/contracts/HyperCertMetadata.sol/IHyperCertMinter";
export { IHyperCertSVG } from "./types/contracts/HyperCertMetadata.sol/IHyperCertSVG";
export { ERC3525SlotEnumerableUpgradeable } from "./types/contracts/ERC3525SlotEnumerableUpgradeable";
export { ERC3525Upgradeable } from "./types/contracts/ERC3525Upgradeable";

// Factories
export { HyperCertMinter__factory as HyperCertMinterFactory } from "./types/factories/contracts/HyperCertMinter__factory";
export { HyperCertSVG__factory as HyperCertSVGFactory } from "./types/factories/contracts/HyperCertSVG__factory";
export { HyperCertMetadata__factory as HyperCertMetadataFactory } from "./types/factories/contracts/HyperCertMetadata.sol/HyperCertMetadata__factory";
export { IHyperCertMinter__factory as IHyperCertMinterFactory } from "./types/factories/contracts/HyperCertMetadata.sol/IHyperCertMinter__factory";
export { IHyperCertSVG__factory as IHyperCertSVGFactory } from "./types/factories/contracts/HyperCertMetadata.sol/IHyperCertSVG__factory";
export { ERC3525SlotEnumerableUpgradeable__factory as ERC3525SlotEnumerableUpgradeableFactory } from "./types/factories/contracts/ERC3525SlotEnumerableUpgradeable__factory";
export { ERC3525Upgradeable__factory as ERC3525UpgradeableFactory } from "./types/factories/contracts/ERC3525Upgradeable__factory";
