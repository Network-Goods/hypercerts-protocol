import hre, { getNamedAccounts } from "hardhat";
import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const deploy: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deploy } = hre.deployments; // we get the deployments and getNamedAccounts which are provided by hardhat-deploy.
  const { deployer } = await getNamedAccounts(); // The deployments field itself contains the deploy function.

  await deploy("ERC3525_Testing", { from: deployer });
};

export default deploy;
deploy.tags = ["local"];
deploy.skip = async hre => hre.network.name !== "hardhat";
