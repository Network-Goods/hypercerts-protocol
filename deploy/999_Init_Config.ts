import { getNamedAccounts } from "hardhat";
import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

import { SVGBackgrounds } from "../src/util/wellKnown";

const deploy: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { execute, read } = hre.deployments;

  const { deployer } = await getNamedAccounts();

  const colorsSize = await read("HyperCertSVG", { from: deployer }, "colorsCounter");

  if (colorsSize == 0) {
    await execute("HyperCertSVG", { from: deployer, log: true }, "addColors", ["#F3556F", "#121933", "#D4BFFF"]); //
    await execute("HyperCertSVG", { from: deployer, log: true }, "addColors", ["#FFBFCA", "#FFFFFF", "#5500FF"]); //
    await execute("HyperCertSVG", { from: deployer, log: true }, "addColors", ["#25316D", "#121933", "#80E5D3"]); //
    await execute("HyperCertSVG", { from: deployer, log: true }, "addColors", ["#25316D", "#FFFFFF", "#F3556F"]); //
    await execute("HyperCertSVG", { from: deployer, log: true }, "addColors", ["#80E5D3", "#FFFFFF", "#121933"]); //
    await execute("HyperCertSVG", { from: deployer, log: true }, "addColors", ["#FEF5AC", "#FFFFFF", "#25316D"]); //
    await execute("HyperCertSVG", { from: deployer, log: true }, "addColors", ["#F3556F", "#121933", "#FFBFCA"]); //
    await execute("HyperCertSVG", { from: deployer, log: true }, "addColors", ["#5500FF", "#121933", "#FFCC00"]); //
  }

  const currentBackground = await read("HyperCertSVG", { from: deployer }, "backgrounds", 0);

  if (currentBackground.length == 0) {
    await execute("HyperCertSVG", { from: deployer, log: true }, "addBackground", SVGBackgrounds[0]);
    await execute("HyperCertSVG", { from: deployer, log: true }, "addBackground", SVGBackgrounds[1]);
    await execute("HyperCertSVG", { from: deployer, log: true }, "addBackground", SVGBackgrounds[2]);
    await execute("HyperCertSVG", { from: deployer, log: true }, "addBackground", SVGBackgrounds[3]);
    await execute("HyperCertSVG", { from: deployer, log: true }, "addBackground", SVGBackgrounds[4]);
    await execute("HyperCertSVG", { from: deployer, log: true }, "addBackground", SVGBackgrounds[5]);
    await execute("HyperCertSVG", { from: deployer, log: true }, "addBackground", SVGBackgrounds[6]);
    await execute("HyperCertSVG", { from: deployer, log: true }, "addBackground", SVGBackgrounds[7]);
  }
};

export default deploy;
deploy.tags = ["local", "staging", "init"];
deploy.dependencies = ["HyperCertSVG", "HyperCertMinter"];
deploy.runAtTheEnd = true;
