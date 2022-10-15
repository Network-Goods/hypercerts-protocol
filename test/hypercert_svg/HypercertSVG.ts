import { expect } from "chai";
import { format } from "date-fns";
import { promises as fs } from "fs";
import { ethers } from "hardhat";
import { parseXml } from "libxmljs";

import { HyperCertSVG as SVG } from "../../src/types";
// import { SVGBackgrounds } from "../../src/util/wellKnown";
import { setupTestSVG } from "../setup";
import { randomScopes } from "../utils";
import { DEFAULT_ADMIN_ROLE, HyperCertSVG, SVGBackgrounds, UPGRADER_ROLE } from "../wellKnown";

type InputType = {
  name: string;
  scopesOfImpact: string[];
  workTimeframe: [number, number];
  impactTimeframe: [number, number];
  units: number;
  totalUnits: number;
};

const input1: InputType = {
  name: "TestSVG_S",
  scopesOfImpact: ["Developing SVG rendering"],
  workTimeframe: [1640998800, 1643590800],
  impactTimeframe: [1643677200, 1646010000],
  units: 333,
  totalUnits: 1000,
};

const input2: InputType = {
  name: "TestSVG2_M",
  scopesOfImpact: ["Developing further SVG rendering", "tralalalala"],
  workTimeframe: [1640998800, 1643590800],
  impactTimeframe: [1643677200, 1646010000],
  units: 500,
  totalUnits: 1000,
};

const input3: InputType = {
  name: "TestSVG_L",
  scopesOfImpact: Object.values(randomScopes(100)),
  workTimeframe: [1640998800, 1643590800],
  impactTimeframe: [1643677200, 1646010000],
  units: 500,
  totalUnits: 1000,
};

const input4: InputType = {
  name: "TestSVG_XL_____________________",
  scopesOfImpact: Object.keys(randomScopes(200)),
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
  return `${percentage} %`;
};
const truncate = (scope: string, maxLength: number = 30) =>
  scope.length <= maxLength ? scope : `${scope.substring(0, maxLength - 3)}...`;

const generateAndValidateSVG = async (
  name: string,
  input: InputType,
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
  await validate(svg, input, fraction);
};

const validate = async (svg: string, input: InputType, fraction: boolean = false) => {
  const baseUrl = `${BASE_PATH}xsd/`;
  const xsd = await fs.readFile(`${baseUrl}svg.xsd`, { encoding: "utf-8" });
  const xsdDoc = parseXml(xsd, { baseUrl });
  const svgDoc = parseXml(svg);
  svgDoc.validate(xsdDoc);

  const truncName = truncate(input.name);
  expect(svgDoc.find(`//*[@id='name-color']//*[text()='${truncName}']`).length).to.eq(
    1,
    `Name "${truncName}" not found`,
  );
  input.scopesOfImpact.slice(0, 2).forEach(scope => {
    const truncScope = truncate(scope);
    expect(svgDoc.find(`//*[@id='description-color']//*[text()='${truncScope}']`).length).to.eq(
      1,
      `Scope "${truncScope}" not found`,
    );
  });
  expect(svgDoc.find(`//*[@id='work-period-color']//*[text()='${formatTimeframe(input.workTimeframe)}']`).length).to.eq(
    1,
    "Work period not found",
  );
  if (fraction) {
    expect(svgDoc.find(`//*[@id='fraction-color']//*[text()='${formatFraction(input)}']`).length).to.eq(
      1,
      "Fraction not found",
    );
  }

  expect(svgDoc.validationErrors.length).to.eq(0, svgDoc.validationErrors.join("\n"));
};

describe("Unit tests", function () {
  describe(HyperCertSVG, async function () {
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

    const data = [input1, input2, input3, input4];

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
