import { expect } from "chai";
import { deployments } from "hardhat";

import { ERC3525_Testing, HypercertMinter, HypercertMinterUpgrade } from "../src/types";
import { ERC3525, HypercertMinter_Current, ImpactScopes, Rights, WorkScopes } from "./wellKnown";

export type HypercertContract = HypercertMinter | HypercertMinterUpgrade;
export type ERC3525 = ERC3525_Testing;

export type AddressedHypercertMinterContract = {
  address: string;
  minter: HypercertContract;
};

export type HypercertCollection = {
  minter: HypercertContract;
  deployer: AddressedHypercertMinterContract;
  user: AddressedHypercertMinterContract;
  anon: AddressedHypercertMinterContract;
};

export const setupTestERC3525 = deployments.createFixture(
  async ({ deployments, getNamedAccounts, ethers }, _options) => {
    await deployments.fixture(); // ensure you start from a fresh deployments
    const { deployer, user, anon } = await getNamedAccounts();

    // Contracts
    const sft: ERC3525 = await ethers.getContract(ERC3525);
    await sft.initialize();

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

const setupTest = deployments.createFixture<
  HypercertCollection,
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
  const minter: HypercertContract = await ethers.getContract(HypercertMinter_Current);

  // Account config
  const setupAddress = async (address: string) => {
    return {
      address: address,
      minter: <HypercertContract>await ethers.getContract(HypercertMinter_Current, address),
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
  contract: HypercertContract,
  contractAtAddress?: HypercertContract,
  impactScopes = ImpactScopes,
) => {
  for (const [hash, text] of Object.entries(impactScopes)) {
    await expect((contractAtAddress ?? contract).addImpactScope(text))
      .to.emit(contract, "ImpactScopeAdded")
      .withArgs(hash, text);
  }
};

export const setupRights = async (
  contract: HypercertContract,
  contractAtAddress?: HypercertContract,
  rights = Rights,
) => {
  for (const [hash, text] of Object.entries(rights)) {
    await expect((contractAtAddress ?? contract).addRight(text))
      .to.emit(contract, "RightAdded")
      .withArgs(hash, text);
  }
};

export const setupWorkScopes = async (
  contract: HypercertContract,
  contractAtAddress?: HypercertContract,
  workScopes = WorkScopes,
) => {
  for (const [hash, text] of Object.entries(workScopes)) {
    await expect((contractAtAddress ?? contract).addWorkScope(text))
      .to.emit(contract, "WorkScopeAdded")
      .withArgs(hash, text);
  }
};

export default setupTest;
