import { ParamType } from "@ethersproject/abi";
import { expect } from "chai";
import { BigNumber } from "ethers";
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
  name: string;
  description: string;
  uri: string;
  version: number;
  fractions: number[];
};

export const newClaim = async (claim?: Partial<Claim>) => {
  const getNamedAccountsAsArray = async () => {
    const { user, anon } = await getNamedAccounts();
    return [user, anon];
  };

  return {
    rights: claim?.rights || Object.keys(Rights),
    workTimeframe: claim?.workTimeframe || [123456789, 123456789],
    impactTimeframe: claim?.impactTimeframe || [987654321, 987654321],
    contributors: claim?.contributors || (await getNamedAccountsAsArray()),
    workScopes: claim?.workScopes || Object.keys(WorkScopes),
    impactScopes: claim?.impactScopes || Object.keys(ImpactScopes),
    name: claim?.name || "Impact Claim 1",
    description: claim?.description || "Impact Claim 1 description",
    uri: claim?.uri || "ipfs://mockedImpactClaim",
    version: claim?.version || 0,
    fractions: claim?.fractions || [100],
  };
};

export const getEncodedImpactClaim = async (claim?: Partial<Claim>) => encodeClaim(await newClaim(claim));

export const encodeClaim = (c: Claim) => {
  const types = [
    "uint256[]",
    "uint256[]",
    "uint256[]",
    "uint64[2]",
    "uint64[2]",
    "address[]",
    "string",
    "string",
    "string",
    "uint8[]",
  ];
  const values = [
    c.rights,
    c.workScopes,
    c.impactScopes,
    c.workTimeframe,
    c.impactTimeframe,
    c.contributors,
    c.name,
    c.description,
    c.uri,
    c.fractions,
  ];

  return encode(types, values);
};

export const getClaimHash = async (claim: Claim) => {
  const { workTimeframe, workScopes, impactTimeframe, impactScopes } = claim;
  const types = ["uint64[2]", "uint256[]", "uint64[2]", "uint256[]"];
  const values = [workTimeframe, workScopes, impactTimeframe, impactScopes];

  return hash256(types, values);
};

export const getClaimSlotID = async (claim: Claim) => {
  return BigNumber.from(await getClaimHash(claim));
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

//TODO check URI strings

//TODO check SVG strings
