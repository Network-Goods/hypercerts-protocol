import { expect } from "chai";
import { BigNumber } from "ethers";
import { ethers, getNamedAccounts } from "hardhat";

import { HypercertMinterV0 } from "../src/types";

// string memory _uri
export const getEncodedImpactClaim = async (options?: {
  rightsID?: number;
  workTimeframe?: number[];
  impactTimeframe?: number[];
  contributors?: string[];
  workScopes?: number[];
  impactScopes?: number[];
  uri?: string;
}) => {
  const { user, anon } = await getNamedAccounts();
  const abiCoder = new ethers.utils.AbiCoder();

  const _rightsID = options?.rightsID || 1;
  const _workTimeframe = options?.workTimeframe || [123456789, 0];
  const _impactTimeframe = options?.impactTimeframe || [987654321, 0];
  const _contributors = options?.contributors || [user, anon];
  const _workScopes = options?.workScopes || [1, 2, 3, 4, 5];
  const _impactScopes = options?.impactScopes || [10, 20, 30, 40, 50];
  const _uri = options?.uri || "ipfs://mockedImpactClaim";

  const types = ["uint256", "uint256[2]", "uint256[2]", "address[]", "uint256[]", "uint256[]", "string"];
  const values = [_rightsID, _workTimeframe, _impactTimeframe, _contributors, _workScopes, _impactScopes, _uri];

  return abiCoder.encode(types, values);
};

export const getClaimHash = async (options: {
  rightsID: number;
  workTimeframe: number[];
  impactTimeframe: number[];
  contributors: string[];
  workScopes: number[];
  impactScopes: number[];
  uri: string;
  version: number;
}) => {
  const abiCoder = new ethers.utils.AbiCoder();

  const _workTimeframe = options.workTimeframe;
  const _impactTimeframe = options.impactTimeframe;
  const _workScopes = options.workScopes;
  const _impactScopes = options.impactScopes;
  const _version = options.version;

  const types = ["uint256[2]", "uint256[]", "uint256[2]", "uint256[]", "uint256"];
  const values = [_workTimeframe, _workScopes, _impactTimeframe, _impactScopes, _version];

  return ethers.utils.keccak256(abiCoder.encode(types, values));
};

export const compareClaimAgainstInput = async (
  claim: HypercertMinterV0.ClaimStructOutput,
  options: {
    rightsID: number;
    workTimeframe: number[];
    impactTimeframe: number[];
    contributors: string[];
    workScopes: number[];
    impactScopes: number[];
    uri: string;
    version: number;
  },
) => {
  expect(claim.rights).to.be.eq(options.rightsID);
  expect(claim.version).to.be.eq(options.version);
  expect(claim.contributors.map((address: string) => address.toLowerCase())).to.be.eql(
    options.contributors.map((addr: string) => addr.toLowerCase()),
  );
  expect(claim.workTimeframe.map((timestamp: BigNumber) => timestamp.toNumber())).to.be.eql(options.workTimeframe);
  expect(claim.workScopes.map((scope: BigNumber) => scope.toNumber())).to.be.eql(options.workScopes);
  expect(claim.impactTimeframe.map((timestamp: BigNumber) => timestamp.toNumber())).to.be.eql(options.impactTimeframe);
  expect(claim.impactScopes.map((scope: BigNumber) => scope.toNumber())).to.be.eql(options.impactScopes);
};
