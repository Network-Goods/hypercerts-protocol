import { getNamedAccounts } from "hardhat";
import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

import { SVGBackgrounds } from "../src/util/wellKnown";

const deploy: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { execute, read } = hre.deployments;

  const { deployer } = await getNamedAccounts();

  const currentBackground = await read("HyperCertSVG", { from: deployer }, "backgrounds", 0);

  if (currentBackground.length == 0) {
    await execute("HyperCertSVG", { from: deployer, log: true }, "addBackground", SVGBackgrounds[0]);
  }
};

export default deploy;
deploy.tags = ["local", "staging", "init"];
deploy.dependencies = ["HyperCertSVG", "HyperCertMinter"];
deploy.runAtTheEnd = true;
