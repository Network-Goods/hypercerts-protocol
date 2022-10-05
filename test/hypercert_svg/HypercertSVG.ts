import { expect } from "chai";
import { promises as fs } from "fs";
import { ethers } from "hardhat";

import { HypercertSVG as SVG } from "../../src/types";
import { HypercertSVG, svgBackground } from "../wellKnown";

describe("Unit tests", function () {
  describe.only("Hypercert SVG", function () {
    it("renders a valid SVG string", async () => {
      const tokenFactory = await ethers.getContractFactory(HypercertSVG);
      const tokenInstance = <SVG>await tokenFactory.deploy();

      await tokenInstance.addBackground(svgBackground);

      const input = {
        name: "TestSVG one two three four five six seven eight",
        scopesOfImpact: ["First scope", "Second scope with filler", "Third scope a bit longer than the first"],
        workTimeframe: [12345678, 87654321],
        impactTimeframe: [87654321, 12345678],
        units: 333,
        totalUnits: 1000,
      };

      const svgFractionString = await tokenInstance.generateSvgFraction(
        input.name,
        input.scopesOfImpact,
        input.workTimeframe,
        input.impactTimeframe,
        input.units,
        input.totalUnits,
      );

      const svgHypercertString = await tokenInstance.generateSvgHypercert(
        input.name,
        input.scopesOfImpact,
        input.workTimeframe,
        input.impactTimeframe,
        input.totalUnits,
      );

      await fs.writeFile("testSvgFraction.svg", svgFractionString);
      await fs.writeFile("testSvgHypercert.svg", svgHypercertString);

      expect(svgFractionString).to.include("svg").to.include(input.name).to.include(input.description);
      expect(svgHypercertString).to.include("svg").to.include(input.name).to.include(input.description);
    });
  });
});
