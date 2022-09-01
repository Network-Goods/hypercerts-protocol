import { expect } from "chai";
import { deployments } from "hardhat";

import { HypercertMinterV0, HypercertMinterV1 } from "../src/types";
import { HypercertMinter_V0, HypercertMinter_V1, ImpactScopes, Rights, WorkScopes } from "./wellKnown";

export type AddressedHypercertMinterV1 = {
  address: string;
  minter: HypercertMinterV1;
};

export type HypercertCollection = {
  minter: HypercertMinterV1;
  deployer: AddressedHypercertMinterV1;
  user: AddressedHypercertMinterV1;
  anon: AddressedHypercertMinterV1;
};

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
  const minter: HypercertMinterV1 = await ethers.getContract(HypercertMinter_V1);

  // Account config
  const setupAddress = async (address: string) => {
    return {
      address: address,
      minter: <HypercertMinterV1>await ethers.getContract(HypercertMinter_V1, address),
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
  contract: HypercertMinterV1 | HypercertMinterV0,
  contractAtAddress?: HypercertMinterV1 | HypercertMinterV0,
  impactScopes = ImpactScopes,
) => {
  for (const [hash, text] of Object.entries(impactScopes)) {
    await expect((contractAtAddress ?? contract).addImpactScope(text))
      .to.emit(contract, "ImpactScopeAdded")
      .withArgs(hash, text);
  }
};

export const setupRights = async (
  contract: HypercertMinterV1 | HypercertMinterV0,
  contractAtAddress?: HypercertMinterV1 | HypercertMinterV0,
  rights = Rights,
) => {
  for (const [hash, text] of Object.entries(rights)) {
    await expect((contractAtAddress ?? contract).addRight(text))
      .to.emit(contract, "RightAdded")
      .withArgs(hash, text);
  }
};

export const setupWorkScopes = async (
  contract: HypercertMinterV1 | HypercertMinterV0,
  contractAtAddress?: HypercertMinterV1 | HypercertMinterV0,
  workScopes = WorkScopes,
) => {
  for (const [hash, text] of Object.entries(workScopes)) {
    await expect((contractAtAddress ?? contract).addWorkScope(text))
      .to.emit(contract, "WorkScopeAdded")
      .withArgs(hash, text);
  }
};

export default setupTest;
