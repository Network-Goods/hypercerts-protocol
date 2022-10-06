import { getNamedAccounts } from "hardhat";
import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const deploy: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deploy, get } = hre.deployments; // we get the deployments and getNamedAccounts which are provided by hardhat-deploy.

  const { deployer } = await getNamedAccounts();
  const HypercertSVG = await get("HyperCertSVG");

  const meta = await deploy("HyperCertMetadata", { from: deployer, args: [HypercertSVG.address] });

  console.log("Deployed metadata generator: " + meta.address);
};

export default deploy;
deploy.tags = ["local", "staging"];
deploy.dependencies = ["HyperCertSVG"];
