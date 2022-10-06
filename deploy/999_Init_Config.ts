import { getNamedAccounts } from "hardhat";
import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

import { SVGBackgrounds } from "../src/util/wellKnown";

const deploy: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { execute } = hre.deployments;

  const { deployer } = await getNamedAccounts();

  await execute("HypercertSVG", { from: deployer, log: true }, "addBackground", SVGBackgrounds[0]);
};

export default deploy;
deploy.tags = ["local", "staging"];
deploy.dependencies = ["HyperCertMinter"];
