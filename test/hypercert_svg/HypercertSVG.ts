import { expect } from "chai";
import { BigNumberish } from "ethers";
import { promises as fs } from "fs";
import { ethers } from "hardhat";
import { parseXml } from "libxmljs";

import { HypercertSVG as SVG } from "../../src/types";
import { PromiseOrValue } from "../../src/types/common";
import { HypercertSVG } from "../wellKnown";

type InputType = {
  name: PromiseOrValue<string>;
  description: PromiseOrValue<string>;
  workTimeframe: [PromiseOrValue<BigNumberish>, PromiseOrValue<BigNumberish>];
  impactTimeframe: [PromiseOrValue<BigNumberish>, PromiseOrValue<BigNumberish>];
  units: PromiseOrValue<BigNumberish>;
  totalUnits: PromiseOrValue<BigNumberish>;
};

const input: InputType = {
  name: "TestSVG",
  description: "Testing SVG rendering",
  workTimeframe: [12345678, 87654321],
  impactTimeframe: [87654321, 12345678],
  units: 333,
  totalUnits: 1000,
};

const generateAndValidateSVG = async (fn: (tokenInstance: SVG) => Promise<string>) => {
  const tokenFactory = await ethers.getContractFactory(HypercertSVG);
  const tokenInstance = <SVG>await tokenFactory.deploy();
  const svg = await fn(tokenInstance);
  await validate(svg);
};

const validate = async (svg: string) => {
  const baseUrl = "test/hypercert_svg/";
  const xsd = await fs.readFile(`${baseUrl}svg.xsd`, { encoding: "utf-8" });
  const xsdDoc = parseXml(xsd, { baseUrl });
  //await fs.writeFile(svg, `${baseUrl}testSvg.svg`);
  const svgDoc = parseXml(svg);
  svgDoc.validate(xsdDoc);

  expect(svgDoc.validationErrors.length).to.eq(0, svgDoc.validationErrors.join("\n"));
  expect(svg).to.include(input.name).to.include(input.description);
};

describe("Unit tests", function () {
  describe("Hypercert SVG", async function () {
    it("should generate valid hypercert SVG", async () => {
      await generateAndValidateSVG(tokenInstance =>
        tokenInstance.generateSvgHypercert(
          input.name,
          input.description,
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
          input.description,
          input.workTimeframe,
          input.impactTimeframe,
          input.units,
          input.totalUnits,
        ),
      );
    });
  });
});
