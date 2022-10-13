import { expect } from "chai";
import { deployments } from "hardhat";

import {
  ERC3525_Testing,
  HyperCertMinter,
  HyperCertMinterUpgrade,
  HyperCertMetadata as Metadata,
  HyperCertSVG as SVG,
} from "../src/types";
import {
  ERC3525,
  HyperCertMetadata,
  HyperCertMinter_Current,
  HyperCertSVG,
  ImpactScopes,
  Rights,
  WorkScopes,
} from "./wellKnown";

export type HyperCertContract = HyperCertMinter | HyperCertMinterUpgrade;
export type ERC3525 = ERC3525_Testing;

export type AddressedHyperCertMinterContract = {
  address: string;
  minter: HyperCertContract;
};

export type HyperCertCollection = {
  minter: HyperCertContract;
  deployer: AddressedHyperCertMinterContract;
  user: AddressedHyperCertMinterContract;
  anon: AddressedHyperCertMinterContract;
};

export const setupTestERC3525 = deployments.createFixture(
  async ({ deployments, getNamedAccounts, ethers }, _options) => {
    await deployments.fixture(); // ensure you start from a fresh deployments
    const { deployer, user, anon } = await getNamedAccounts();

    // Contracts
    const sft: ERC3525 = await ethers.getContract(ERC3525);

    // Account config
    const setupAddress = async (address: string) => {
      return {
        address: address,
        sft: <ERC3525>await ethers.getContract(ERC3525, address),
      };
    };

    // Struct
    return {
      sft,
      deployer: await setupAddress(deployer),
      user: await setupAddress(user),
      anon: await setupAddress(anon),
    };
  },
);

export const setupTestMetadata = deployments.createFixture(
  async ({ deployments, getNamedAccounts, ethers }, _options) => {
    await deployments.fixture(); // ensure you start from a fresh deployments
    const { deployer, user, anon } = await getNamedAccounts();

    // Contracts
    const sft = <Metadata>await ethers.getContract(HyperCertMetadata);

    // Account config
    const setupAddress = async (address: string) => {
      return {
        address: address,
        sft: <Metadata>await ethers.getContract(HyperCertMetadata, address),
      };
    };

    // Struct
    return {
      sft,
      deployer: await setupAddress(deployer),
      user: await setupAddress(user),
      anon: await setupAddress(anon),
    };
  },
);

export const setupTestSVG = deployments.createFixture(async ({ deployments, getNamedAccounts, ethers }, _options) => {
  await deployments.fixture(); // ensure you start from a fresh deployments
  const { deployer, user, anon } = await getNamedAccounts();

  // Contracts
  const sft = <SVG>await ethers.getContract(HyperCertSVG);

  // Account config
  const setupAddress = async (address: string) => {
    return {
      address: address,
      sft: <SVG>await ethers.getContract(HyperCertSVG, address),
    };
  };

  // Struct
  return {
    sft,
    deployer: await setupAddress(deployer),
    user: await setupAddress(user),
    anon: await setupAddress(anon),
  };
});

const setupTest = deployments.createFixture<
  HyperCertCollection,
  {
    impactScopes?: {
      [k: string]: string;
    };
    rights?: {
      [k: string]: string;
    };
    workScopes?: {
      [k: string]: string;
    };
  }
>(async ({ deployments, getNamedAccounts, ethers }, options) => {
  await deployments.fixture(); // ensure you start from a fresh deployments
  const { deployer, user, anon } = await getNamedAccounts();

  // Contracts
  const minter: HyperCertContract = await ethers.getContract(HyperCertMinter_Current);

  // Account config
  const setupAddress = async (address: string) => {
    return {
      address: address,
      minter: <HyperCertContract>await ethers.getContract(HyperCertMinter_Current, address),
    };
  };

  await setupImpactScopes(minter, minter, options?.impactScopes);
  await setupRights(minter, minter, options?.rights);
  await setupWorkScopes(minter, minter, options?.workScopes);

  // Struct
  return {
    minter,
    deployer: await setupAddress(deployer),
    user: await setupAddress(user),
    anon: await setupAddress(anon),
  };
});

export const setupImpactScopes = async (
  contract: HyperCertContract,
  contractAtAddress?: HyperCertContract,
  impactScopes = ImpactScopes,
) => {
  for (const [hash, text] of Object.entries(impactScopes)) {
    await expect((contractAtAddress ?? contract).addImpactScope(text))
      .to.emit(contract, "ImpactScopeAdded")
      .withArgs(hash, text);
  }
};

export const setupRights = async (
  contract: HyperCertContract,
  contractAtAddress?: HyperCertContract,
  rights = Rights,
) => {
  for (const [hash, text] of Object.entries(rights)) {
    await expect((contractAtAddress ?? contract).addRight(text))
      .to.emit(contract, "RightAdded")
      .withArgs(hash, text);
  }
};

export const setupWorkScopes = async (
  contract: HyperCertContract,
  contractAtAddress?: HyperCertContract,
  workScopes = WorkScopes,
) => {
  for (const [hash, text] of Object.entries(workScopes)) {
    await expect((contractAtAddress ?? contract).addWorkScope(text))
      .to.emit(contract, "WorkScopeAdded")
      .withArgs(hash, text);
  }
};

export default setupTest;
