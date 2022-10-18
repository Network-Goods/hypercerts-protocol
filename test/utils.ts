import { ParamType } from "@ethersproject/abi";
import { expect } from "chai";
import { format } from "date-fns";
import { BigNumber, utils } from "ethers";
import { promises as fs } from "fs";
import { ethers, getNamedAccounts } from "hardhat";
import { parseXml } from "libxmljs";

import { HyperCertMinter } from "../src/types";
import { DataApplicationJson, ImpactScopes, LoremIpsum, Rights, WorkScopes } from "./wellKnown";

interface Dictionary<T> {
  [key: string]: T;
}

class Cached<T> {
  _result?: T;
  _init: () => T;
  constructor(initializer: () => T) {
    this._init = initializer;
  }
  value() {
    if (!this._result) {
      this._result = this._init();
    }
    return this._result;
  }
}

export type Claim = {
  rights: string[];
  workTimeframe: [number, number];
  impactTimeframe: [number, number];
  contributors: string[];
  workScopes: string[];
  impactScopes: string[];
  name: string;
  description: string;
  uri: string;
  version: number;
  fractions: number[];
};

type Metadata = {
  name: string;
  description: string;
  external_url: string;
  image: string;
  properties: Dictionary<MetadataProperty>;
};

type MetadataProperty = {
  name: string;
  description: string;
  value: number | string;
  is_intrinsic: boolean;
};

export type SVGInput = {
  name: string;
  impactScopes: string[];
  workTimeframe: [number, number];
  impactTimeframe: [number, number];
  units?: number;
  totalUnits: number;
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

//TODO input types
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
    "uint64[]",
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

const loremIpsumCache = new Cached(() => LoremIpsum.split(/[\s,.]+/).map(s => s.toLowerCase()));

const randomWord = () => {
  const loremIpsum = loremIpsumCache.value();
  const i = Math.floor(Math.random() * loremIpsum.length);
  return loremIpsum[i];
};

export const randomScopes = (limit: number) => {
  const scopes = [];
  for (let i = 0; i < limit; i++) {
    scopes.push(`${randomWord()}-${randomWord()}`);
  }

  return toHashMap(scopes);
};

export const compareClaimAgainstInput = async (claim: HyperCertMinter.ClaimStructOutput, options: Claim) => {
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

export const decode64 = (value: string, header: boolean = true) => {
  const base64String = () => (header ? value.substring(value.indexOf("base64,") + 7) : value);
  return utils.toUtf8String(utils.base64.decode(base64String()));
};

export const subScopeKeysForValues = (claim: Claim, impactScopes: Dictionary<string> | string[]) => {
  const isArray = (obj: Dictionary<string> | string[]): obj is string[] => typeof obj["slice"] === "function";
  const getValues = (scopes: Dictionary<string> | string[]) => (isArray(scopes) ? scopes : Object.values(scopes));

  return {
    rights: claim.rights,
    workTimeframe: claim.workTimeframe,
    impactTimeframe: claim.impactTimeframe,
    contributors: claim.contributors,
    name: claim.name,
    description: claim.description,
    uri: claim.uri,
    version: claim.version,
    fractions: claim.fractions,
    impactScopes: getValues(impactScopes),
    workScopes: claim.workScopes,
  };
};

const sum = (series: number[]) => {
  return series.reduce((previousValue, currentValue) => previousValue + currentValue);
};

export const validateMetadata = async (metadata64: string, expected: string | Claim, units?: number) => {
  expect(metadata64.startsWith(DataApplicationJson)).to.be.true;
  const metadataJson = decode64(metadata64);
  if (typeof expected === "string") expect(metadataJson).to.include(expected);
  if (typeof expected === "object") {
    try {
      const metadata = <Metadata>JSON.parse(metadataJson);

      expect(metadata.name).to.eq(expected.name); //slice because of string splitting
      expect(metadata.description).to.eq(expected.description);
      await validateSVG(
        decode64(metadata.image),
        { ...expected, units, totalUnits: sum(expected.fractions) },
        units !== undefined,
      );
      expect(metadata.external_url).to.eq(expected.uri);
    } catch (error) {
      console.error(error, metadataJson);
      throw error;
    }
  }
};

const formatDate = (unix: number) => format(new Date(unix * 1000), "yyyy-M-d");
const formatTimeframe = (timeframe: [number, number]) => `${formatDate(timeframe[0])} to ${formatDate(timeframe[1])}`;
const formatPercent = (units: number, totalUnits: number) => {
  const percentage = ((units / totalUnits) * 100).toLocaleString("en-us", {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  });
  return `${percentage} %`;
};
const truncate = (scope: string, maxLength: number = 23) =>
  scope.length <= maxLength ? scope : `${scope.substring(0, maxLength - 3)}...`;

export const validateSVG = async (svg: string, expected: SVGInput, fraction: boolean = false) => {
  const baseUrl = "src/xsd/";
  const xsd = await fs.readFile(`${baseUrl}svg.xsd`, { encoding: "utf-8" });
  const xsdDoc = parseXml(xsd, { baseUrl });
  const svgDoc = parseXml(svg);
  svgDoc.validate(xsdDoc);

  const nameParts = expected.name.split(" ");
  const svgName = svgDoc.get("//*[@id='name-color']")?.text();
  for (let i = 0; i < Math.min(nameParts.length, 2); i++) {
    expect(svgName).to.contain(nameParts[i].substring(0, 10), `Name "${nameParts[i]}" not found: ${svg}`);
  }

  const truncScope = truncate(expected.impactScopes[0]);
  expect(svgDoc.get("//*[@id='scope-impact-color']")?.text()).to.eq(
    truncScope,
    `Scope "${truncScope}" not found: ${svg}`,
  );

  expect(svgDoc.get("//*[@id='work-period-color']")?.text()).to.eq(
    formatTimeframe(expected.workTimeframe),
    `Work period not found: ${svg}`,
  );

  if (fraction && expected.units) {
    const percentage = formatPercent(expected.units, expected.totalUnits);
    expect(svgDoc.get("//*[@id='fraction-color']")?.text()).to.eq(
      percentage,
      `Percentage ${percentage} not found: ${svg}`,
    );
  }

  expect(svgDoc.validationErrors.length).to.eq(0, svgDoc.validationErrors.join("\n"));
};
