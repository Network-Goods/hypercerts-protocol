import { getNamedAccounts } from "hardhat";
import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const deploy: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deploy, get } = hre.deployments; // we get the deployments and getNamedAccounts which are provided by hardhat-deploy.

  const { deployer } = await getNamedAccounts();
  const HypercertSVG = await get("HypercertSVG");

  await deploy("HypercertMetadata", { from: deployer, args: [HypercertSVG.address] });
};

export default deploy;
deploy.tags = ["local", "staging"];
deploy.dependencies = ["HypercertSVG"];
