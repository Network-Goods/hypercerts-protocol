import { expect } from "chai";
import { promises as fs } from "fs";
import { ethers } from "hardhat";

import { HypercertSVG } from "../../src/types";
import { Hypercert_SVG } from "../wellKnown";

describe.only("Unit tests", function () {
  describe("Hypercert SVG", function () {
    it("is an initializable ERC3525 contract", async () => {
      const tokenFactory = await ethers.getContractFactory(Hypercert_SVG);
      const tokenInstance = <HypercertSVG>await tokenFactory.deploy();

      const input = {
        name: "TestSVG",
        description: "Testing SVG rendering",
        hypercertId: 420,
        fractionId: 69,
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
        input.hypercertId,
        input.fractionId,
        input.units,
        input.totalUnits,
      );

      console.log(svgString);
      await fs.writeFile("testSVG.svg", svgString);

      expect(svgString).to.include("svg").to.include(input.name).to.include(input.description);
    });
  });
});
