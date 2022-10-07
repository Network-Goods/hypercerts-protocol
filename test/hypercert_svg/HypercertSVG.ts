import { expect } from "chai";
import { format } from "date-fns";
import { promises as fs } from "fs";
import { ethers } from "hardhat";
import { parseXml } from "libxmljs";

import { HyperCertSVG as SVG } from "../../src/types";
import { SVGBackgrounds } from "../../src/util/wellKnown";
import { randomScopes } from "../utils";
import { HyperCertSVG } from "../wellKnown";

type InputType = {
  name: string;
  scopesOfImpact: string[];
  workTimeframe: [number, number];
  impactTimeframe: [number, number];
  units: number;
  totalUnits: number;
};

const input1: InputType = {
  name: "TestSVG_light",
  scopesOfImpact: ["Developing SVG rendering"],
  workTimeframe: [1640998800, 1643590800],
  impactTimeframe: [1643677200, 1646010000],
  units: 333,
  totalUnits: 1000,
};

const input2: InputType = {
  name: "TestSVG2_medium",
  scopesOfImpact: ["Developing further SVG rendering", "tralalalala"],
  workTimeframe: [1640998800, 1643590800],
  impactTimeframe: [1643677200, 1646010000],
  units: 500,
  totalUnits: 1000,
};

const input3: InputType = {
  name: "TestSVG_heavy",
  scopesOfImpact: Object.keys(randomScopes(100)),
  workTimeframe: [1640998800, 1643590800],
  impactTimeframe: [1643677200, 1646010000],
  units: 500,
  totalUnits: 1000,
};

const BASE_PATH = "test/hypercert_svg/";

const formatDate = (unix: number) => format(new Date(unix * 1000), "yyyy-M-d");
const formatTimeframe = (timeframe: [number, number]) => `${formatDate(timeframe[0])} > ${formatDate(timeframe[1])}`;

const formatFraction = (input: InputType) => {
  const percentage = ((input.units / input.totalUnits) * 100).toLocaleString("en-us", {
    minimumFractionDigits: 2,
  });
  console.log(percentage);
  return `${percentage} %`;
};

const generateAndValidateSVG = async (
  name: string,
  input: InputType,
  fn: (tokenInstance: SVG) => Promise<string>,
  fraction: boolean = false,
) => {
  const tokenFactory = await ethers.getContractFactory(HyperCertSVG);
  const tokenInstance = <SVG>await tokenFactory.deploy();
  await tokenInstance.addBackground(SVGBackgrounds[0]);
  const svg = await fn(tokenInstance);
  await fs.writeFile(`${BASE_PATH}test_${name}.svg`, svg);
  await validate(svg, input, fraction);
};

const validate = async (svg: string, input: InputType, fraction: boolean = false) => {
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
  expect(
    svgDoc.find(`//*[@id='work-period-color']//*[text()='Work Period: ${formatTimeframe(input.workTimeframe)}']`)
      .length,
  ).to.eq(1, "Work period not found");
  expect(
    svgDoc.find(`//*[@id='impact-period-color']//*[text()='Impact Period: ${formatTimeframe(input.impactTimeframe)}']`)
      .length,
  ).to.eq(1, "Impact period not found");
  expect(
    svgDoc.find(`//*[@id='impact-period-color']//*[text()='Impact Period: ${formatTimeframe(input.impactTimeframe)}']`)
      .length,
  ).to.eq(1, "Impact period not found");
  if (fraction) {
    expect(svgDoc.find(`//*[@id='fraction-color']//*[text()='${formatFraction(input)}']`).length).to.eq(
      1,
      "Fraction not found",
    );
  }

  expect(svgDoc.validationErrors.length).to.eq(0, svgDoc.validationErrors.join("\n"));
};

describe("Unit tests", function () {
  describe.only("HyperCert SVG", async function () {
    const data = [input1, input2, input3];

    data.forEach(input => {
      it(`should generate valid hypercert SVG (${input.name})`, async () => {
        await generateAndValidateSVG(`hypercert_${input.name.toLowerCase()}`, input, tokenInstance =>
          tokenInstance.generateSvgHyperCert(
            input.name,
            input.scopesOfImpact,
            input.workTimeframe,
            input.impactTimeframe,
            input.totalUnits,
          ),
        );
      });

      it(`should generate valid token SVG (${input.name})`, async () => {
        await generateAndValidateSVG(
          `fraction_${input.name.toLowerCase()}`,
          input,
          tokenInstance =>
            tokenInstance.generateSvgFraction(
              input.name,
              input.scopesOfImpact,
              input.workTimeframe,
              input.impactTimeframe,
              input.units,
              input.totalUnits,
            ),
          true,
        );
      });
    });
  });
});
