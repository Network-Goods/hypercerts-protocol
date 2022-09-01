import { ParamType } from "@ethersproject/abi";
import { expect } from "chai";
import { ethers, getNamedAccounts } from "hardhat";

import { HypercertMinterV0 } from "../src/types";
import { ImpactScopes, LoremIpsum, Rights, WorkScopes } from "./wellKnown";

export type Claim = {
  rights: string[];
  workTimeframe: number[];
  impactTimeframe: number[];
  contributors: string[];
  workScopes: string[];
  impactScopes: string[];
  uri: string;
  version: number;
};

export const getEncodedImpactClaim = async (claim?: Partial<Claim>) => {
  const { user, anon } = await getNamedAccounts();

  const rights = claim?.rights || Object.keys(Rights);
  const workTimeframe = claim?.workTimeframe || [123456789, 123456789];
  const impactTimeframe = claim?.impactTimeframe || [987654321, 987654321];
  const contributors = claim?.contributors || [user, anon];
  const workScopes = claim?.workScopes || Object.keys(WorkScopes);
  const impactScopes = claim?.impactScopes || Object.keys(ImpactScopes);
  const uri = claim?.uri || "ipfs://mockedImpactClaim";

  const types = ["uint256[]", "uint256[]", "uint256[]", "uint64[2]", "uint64[2]", "address[]", "string"];
  const values = [rights, workScopes, impactScopes, workTimeframe, impactTimeframe, contributors, uri];

  return encode(types, values);
};

export const getClaimHash = async (claim: Claim) => {
  const { workTimeframe, workScopes, impactTimeframe, impactScopes, version } = claim;
  const types = ["uint64[2]", "uint256[]", "uint64[2]", "uint256[]", "uint256"];
  const values = [workTimeframe, workScopes, impactTimeframe, impactScopes, version];

  return hash256(types, values);
};

export const encode = (
  types: ReadonlyArray<string | ParamType>,
  values: ReadonlyArray<number | number[] | bigint | bigint[] | string | string[]>,
) => new ethers.utils.AbiCoder().encode(types, values);

export const hash256 = (
  types: ReadonlyArray<string | ParamType>,
  values: ReadonlyArray<number | number[] | bigint | bigint[] | string | string[]>,
) => ethers.utils.keccak256(encode(types, values));

export const toHashMap = (array: string[]) => Object.fromEntries(array.map(s => [hash256(["string"], [s]), s]));

export const randomScopes = (limit?: number) => {
  const loremIpsum = LoremIpsum.split(/[\s,.]+/).map(s => s.toLowerCase());
  const l = loremIpsum.length;
  const scopes = [];

  for (let i = 0; i < (limit ?? l); i++) {
    scopes.push(`${loremIpsum[Math.random() * l]}-${loremIpsum[Math.random() * l]}`);
  }

  return toHashMap(scopes);
};

export const compareClaimAgainstInput = async (claim: HypercertMinterV0.ClaimStructOutput, options: Claim) => {
  expect(claim.rights).to.be.eql(options.rights);
  expect(claim.version).to.be.eq(options.version);

  expect(claim.contributors.map(address => address.toLowerCase())).to.be.eql(
    options.contributors.map(addr => addr.toLowerCase()),
  );
  expect(claim.workTimeframe.map(timestamp => timestamp.toNumber())).to.be.eql(options.workTimeframe);
  expect(claim.workScopes).to.be.eql(options.workScopes);
  expect(claim.impactTimeframe.map(timestamp => timestamp.toNumber())).to.be.eql(options.impactTimeframe);
  expect(claim.impactScopes).to.be.eql(options.impactScopes);
};
