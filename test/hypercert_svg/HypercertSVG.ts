import { expect } from "chai";
import { promises as fs } from "fs";
import { ethers } from "hardhat";

import { HypercertSVG as SVG } from "../../src/types";
import { HypercertSVG } from "../wellKnown";

describe("Unit tests", function () {
  describe("Hypercert SVG", function () {
    it("renders a valid SVG string", async () => {
      const tokenFactory = await ethers.getContractFactory(HypercertSVG);
      const tokenInstance = <SVG>await tokenFactory.deploy();

      const input = {
        name: "TestSVG",
        description: "Testing SVG rendering",
        workTimeframe: [12345678, 87654321],
        impactTimeframe: [87654321, 12345678],
        units: 333,
        totalUnits: 1000,
      };

      const svgString = await tokenInstance.generateSVG(
        input.name,
        input.description,
        input.workTimeframe,
        input.impactTimeframe,
        input.units,
        input.totalUnits,
      );

      await fs.writeFile("testSVG.svg", svgString);

      expect(svgString).to.include("svg").to.include(input.name).to.include(input.description);
    });
  });
});
