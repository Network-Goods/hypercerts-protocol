import { expect } from "chai";
import { BigNumberish } from "ethers";
import { promises as fs } from "fs";
import { ethers } from "hardhat";
import { parseXml } from "libxmljs";

import { HyperCertSVG as SVG } from "../../src/types";
import { PromiseOrValue } from "../../src/types/common";
import { HyperCertSVG } from "../wellKnown";

//TODO not sure if needed, Typescript should infer this from contract types
type InputType = {
  name: PromiseOrValue<string>;
  scopesOfImpact: PromiseOrValue<string>[];
  workTimeframe: [PromiseOrValue<BigNumberish>, PromiseOrValue<BigNumberish>];
  impactTimeframe: [PromiseOrValue<BigNumberish>, PromiseOrValue<BigNumberish>];
  units: PromiseOrValue<BigNumberish>;
  totalUnits: PromiseOrValue<BigNumberish>;
};

const input: InputType = {
  name: "TestSVG",
  scopesOfImpact: ["Developing SVG rendering", "Trololololololol"],
  workTimeframe: [12345678, 87654321],
  impactTimeframe: [87654321, 12345678],
  units: 333,
  totalUnits: 1000,
};

const BASE_PATH = "test/hypercert_svg/";

//TODO add uploading `svgBackground` using `addBackground` method
const generateAndValidateSVG = async (fn: (tokenInstance: SVG) => Promise<string>) => {
  const tokenFactory = await ethers.getContractFactory(HyperCertSVG);
  const tokenInstance = <SVG>await tokenFactory.deploy();
  const svg = await fn(tokenInstance);
  // await fs.writeFile(`${BASE_PATH}test.svg`, svg);
  await validate(svg);
};

const validate = async (svg: string) => {
  const baseUrl = `${BASE_PATH}xsd/`;
  const xsd = await fs.readFile(`${baseUrl}svg.xsd`, { encoding: "utf-8" });
  const xsdDoc = parseXml(xsd, { baseUrl });
  const svgDoc = parseXml(svg);
  svgDoc.validate(xsdDoc);

  expect(svgDoc.find(`//*[@id='name-color']//*[text()='${input.name}']`).length).to.eq(1);
  // expect(svgDoc.find("//description")).to.include(input.description);
  expect(svgDoc.validationErrors.length).to.eq(0, svgDoc.validationErrors.join("\n"));
};

describe("Unit tests", function () {
  describe("Hypercert SVG", async function () {
    it("should generate valid hypercert SVG", async () => {
      await generateAndValidateSVG(tokenInstance =>
        tokenInstance.generateSvgHyperCert(
          input.name,
          input.scopesOfImpact,
          input.workTimeframe,
          input.impactTimeframe,
          input.totalUnits,
        ),
      );
    });

    it("should generate valid token SVG", async () => {
      await generateAndValidateSVG(tokenInstance =>
        tokenInstance.generateSvgFraction(
          input.name,
          input.scopesOfImpact,
          input.workTimeframe,
          input.impactTimeframe,
          input.units,
          input.totalUnits,
        ),
      );
    });
  });
});
