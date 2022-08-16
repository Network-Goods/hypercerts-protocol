import { ethers, getNamedAccounts } from "hardhat";

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
