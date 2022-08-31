import { expect } from "chai";
import { deployments } from "hardhat";

import { HypercertMinterV0 } from "../src/types";
import { Contracts, ImpactScopes, Rights, WorkScopes } from "./wellKnown";

const { HypercertMinter } = Contracts;

export type AddressedHypercertMinterV0 = {
  address: string;
  minter: HypercertMinterV0;
};

export type HypercertCollection = {
  minter: HypercertMinterV0;
  deployer: AddressedHypercertMinterV0;
  user: AddressedHypercertMinterV0;
  anon: AddressedHypercertMinterV0;
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
  const deployment = await deployments.get(HypercertMinter);
  const { deployer, user, anon } = await getNamedAccounts();

  // Contracts
  const minter = <HypercertMinterV0>await ethers.getContractAt(HypercertMinter, deployment.address);

  // Account config
  const setupAddress = async (address: string) => {
    return {
      address: address,
      minter: <HypercertMinterV0>(
        await ethers.getContractAt(HypercertMinter, deployment.address, await ethers.getSigner(address))
      ),
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
  contract: HypercertMinterV0,
  contractAtAddress?: HypercertMinterV0,
  impactScopes = ImpactScopes,
) => {
  for (const [hash, text] of Object.entries(impactScopes)) {
    await expect((contractAtAddress ?? contract).addImpactScope(text))
      .to.emit(contract, "ImpactScopeAdded")
      .withArgs(hash, text);
  }
};

export const setupRights = async (
  contract: HypercertMinterV0,
  contractAtAddress?: HypercertMinterV0,
  rights = Rights,
) => {
  for (const [hash, text] of Object.entries(rights)) {
    await expect((contractAtAddress ?? contract).addRight(text))
      .to.emit(contract, "RightAdded")
      .withArgs(hash, text);
  }
};

export const setupWorkScopes = async (
  contract: HypercertMinterV0,
  contractAtAddress?: HypercertMinterV0,
  workScopes = WorkScopes,
) => {
  for (const [hash, text] of Object.entries(workScopes)) {
    await expect((contractAtAddress ?? contract).addWorkScope(text))
      .to.emit(contract, "WorkScopeAdded")
      .withArgs(hash, text);
  }
};

export default setupTest;
