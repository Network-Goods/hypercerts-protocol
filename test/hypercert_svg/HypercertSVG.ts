import { expect } from "chai";
import { promises as fs } from "fs";
import { ethers } from "hardhat";

import { HyperCertSVG as SVG } from "../../src/types";
import { setupTestSVG } from "../setup";
import { randomScopes, validateSVG } from "../utils";
import { DEFAULT_ADMIN_ROLE, HyperCertSVG, SVGBackgrounds, UPGRADER_ROLE } from "../wellKnown";

type SVGInput = {
  name: string;
  impactScopes: string[];
  workTimeframe: [number, number];
  impactTimeframe: [number, number];
  units: number;
  totalUnits: number;
};

const input1: SVGInput = {
  name: "TestSVG_S",
  impactScopes: ["Developing SVG rendering"],
  workTimeframe: [1640998800, 1643590800],
  impactTimeframe: [1643677200, 1646010000],
  units: 333,
  totalUnits: 1000,
};

const input2: SVGInput = {
  name: "TestSVG2_M",
  impactScopes: ["Developing further SVG rendering", "tralalalala"],
  workTimeframe: [1640998800, 1643590800],
  impactTimeframe: [1643677200, 1646010000],
  units: 500,
  totalUnits: 1000,
};

const input3: SVGInput = {
  name: "TestSVG_L",
  impactScopes: Object.values(randomScopes(100)),
  workTimeframe: [1640998800, 1643590800],
  impactTimeframe: [1643677200, 1646010000],
  units: 500,
  totalUnits: 1000,
};

const input4: SVGInput = {
  name: "TestSVG_XL: extraordinarily capacious",
  impactScopes: Object.values(randomScopes(200)),
  workTimeframe: [1640998800, 1643590800],
  impactTimeframe: [1643677200, 1646010000],
  units: 500,
  totalUnits: 1000,
};

const input5: SVGInput = {
  name: "TestSVG_XL: OneTwoThreeFourFiveSixSevenEightNine",
  impactScopes: Object.values(randomScopes(200)),
  workTimeframe: [1640998800, 1643590800],
  impactTimeframe: [1643677200, 1646010000],
  units: 500,
  totalUnits: 1000,
};

const input6: SVGInput = {
  name: "Supercalifragilisticexpialidocious",
  impactScopes: Object.values(randomScopes(200)),
  workTimeframe: [1640998800, 1643590800],
  impactTimeframe: [1643677200, 1646010000],
  units: 500,
  totalUnits: 1000,
};

const BASE_PATH = "test/hypercert_svg/";

const generateAndValidateSVG = async (
  name: string,
  input: SVGInput,
  fn: (tokenInstance: SVG) => Promise<string>,
  fraction: boolean = false,
) => {
  const tokenFactory = await ethers.getContractFactory(HyperCertSVG);
  const tokenInstance = <SVG>await tokenFactory.deploy();

  //Primary, labels, background
  await tokenInstance.addColors(["#F3556F", "#121933", "#D4BFFF"]); //
  await tokenInstance.addColors(["#FFBFCA", "#FFFFFF", "#5500FF"]); //
  await tokenInstance.addColors(["#25316D", "#121933", "#80E5D3"]); //
  await tokenInstance.addColors(["#25316D", "#FFFFFF", "#F3556F"]); //
  await tokenInstance.addColors(["#80E5D3", "#FFFFFF", "#121933"]); //
  await tokenInstance.addColors(["#FEF5AC", "#FFFFFF", "#25316D"]); //
  await tokenInstance.addColors(["#F3556F", "#121933", "#FFBFCA"]); //
  await tokenInstance.addColors(["#5500FF", "#121933", "#FFCC00"]); //

  await tokenInstance.addBackground(SVGBackgrounds[0]);
  await tokenInstance.addBackground(SVGBackgrounds[1]);
  await tokenInstance.addBackground(SVGBackgrounds[2]);
  await tokenInstance.addBackground(SVGBackgrounds[3]);
  await tokenInstance.addBackground(SVGBackgrounds[4]);
  await tokenInstance.addBackground(SVGBackgrounds[5]);
  await tokenInstance.addBackground(SVGBackgrounds[6]);
  await tokenInstance.addBackground(SVGBackgrounds[7]);

  const svg = await fn(tokenInstance);
  await fs.writeFile(`${BASE_PATH}test_${name}.svg`, svg);
  await validateSVG(svg, input, fraction);
};

describe("Unit tests", function () {
  describe.only(HyperCertSVG, async function () {
    it("is an initializable contract", async () => {
      const tokenFactory = await ethers.getContractFactory(HyperCertSVG);
      const tokenInstance = <SVG>await tokenFactory.deploy();

      await expect(tokenInstance.initialize()).to.be.revertedWith("Initializable: contract is already initialized");
    });

    it("is a UUPS-upgradeable contract", async () => {
      const { sft } = await setupTestSVG();

      await expect(sft.proxiableUUID()).to.be.revertedWith("UUPSUpgradeable: must not be called through delegatecall");
    });

    const roles = <[string, string][]>[
      ["admin", DEFAULT_ADMIN_ROLE],
      ["upgrader", UPGRADER_ROLE],
    ];

    roles.forEach(([name, role]) => {
      it(`supports ${name} role`, async function () {
        const { sft, user, deployer } = await setupTestSVG();

        expect(await sft.hasRole(role, deployer.address)).to.be.true;
        expect(await sft.hasRole(role, user.address)).to.be.false;

        await expect(user.sft.grantRole(role, user.address)).to.be.revertedWith(
          `AccessControl: account ${user.address.toLowerCase()} is missing role ${DEFAULT_ADMIN_ROLE}`,
        );

        await expect(deployer.sft.grantRole(role, user.address))
          .to.emit(sft, "RoleGranted")
          .withArgs(role, user.address, deployer.address);
      });
    });

    const data = [input1, input2, input3, input4, input5, input6];

    data.forEach(input => {
      it(`should generate valid hypercert SVG (${input.name})`, async () => {
        await generateAndValidateSVG(`hypercert_${input.name.toLowerCase()}`, input, tokenInstance =>
          tokenInstance.generateSvgHyperCert(
            input.name,
            input.impactScopes,
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
              input.impactScopes,
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
