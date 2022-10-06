import { expect } from "chai";
import { promises as fs } from "fs";
import { ethers } from "hardhat";
import { parseXml } from "libxmljs";

import { HypercertSVG as SVG } from "../../src/types";
import { SVGBackgrounds } from "../../src/util/wellKnown";
import { HypercertSVG } from "../wellKnown";

type InputType = {
  name: string;
  scopesOfImpact: string[];
  workTimeframe: [number, number];
  impactTimeframe: [number, number];
  units: number;
  totalUnits: number;
};

const input: InputType = {
  name: "TestSVG",
  scopesOfImpact: ["Developing SVG rendering"],
  workTimeframe: [1640998800, 1643590800],
  impactTimeframe: [1643677200, 1646010000],
  units: 333,
  totalUnits: 1000,
};

const BASE_PATH = "test/hypercert_svg/";

const formatDate = (unix: number) =>
  new Date(unix * 1000).toLocaleString("en-US", { year: "numeric", month: "numeric", day: "numeric" });

const generateAndValidateSVG = async (name: string, fn: (tokenInstance: SVG) => Promise<string>) => {
  const tokenFactory = await ethers.getContractFactory(HypercertSVG);
  const tokenInstance = <SVG>await tokenFactory.deploy();
  await tokenInstance.addBackground(SVGBackgrounds[0]);
  console.log("deployed SVG and added background");
  const svg = await fn(tokenInstance);
  await fs.writeFile(`${BASE_PATH}test_${name}.svg`, svg);
  await validate(svg);
};

const validate = async (svg: string) => {
  const baseUrl = `${BASE_PATH}xsd/`;
  const xsd = await fs.readFile(`${baseUrl}svg.xsd`, { encoding: "utf-8" });
  const xsdDoc = parseXml(xsd, { baseUrl });
  const svgDoc = parseXml(svg);
  svgDoc.validate(xsdDoc);

  expect(svgDoc.find(`//*[@id='name-color']//*[text()='${input.name}']`).length).to.eq(1, "Name not found");
  expect(svgDoc.find(`//*[@id='description-color']//*[text()='${input.scopesOfImpact[0]}']`).length).to.eq(
    1,
    "Description not found",
  );
  // const workPeriod = `Work Period: ${formatDate(input.workTimeframe[0])} > ${formatDate(input.workTimeframe[1])}`;
  // console.log(workPeriod);
  // expect(svgDoc.find(`//*[@id='work-period-color']//*[text()='${workPeriod}']`).length).to.eq(
  //   1,
  //   "Work period not found",
  // );
  // expect(
  //   svgDoc.find(
  //     `//*[@id='impact-period-color']//*[text()='Impact Period: ${formatDate(input.impactTimeframe[0])} > ${formatDate(
  //       input.impactTimeframe[1],
  //     )}']`,
  //   ).length,
  // ).to.eq(1, "Impact period not found");
  expect(svgDoc.validationErrors.length).to.eq(0, svgDoc.validationErrors.join("\n"));
};

describe("Unit tests", function () {
  describe("Hypercert SVG", async function () {
    it("should generate valid hypercert SVG", async () => {
      await generateAndValidateSVG("hypercert", tokenInstance =>
        tokenInstance.generateSvgHypercert(
          input.name,
          input.scopesOfImpact,
          input.workTimeframe,
          input.impactTimeframe,
          input.totalUnits,
        ),
      );
    });

    it("should generate valid token SVG", async () => {
      await generateAndValidateSVG("fraction", tokenInstance =>
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
