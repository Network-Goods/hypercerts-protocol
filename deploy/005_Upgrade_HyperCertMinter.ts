import { ethers, upgrades } from "hardhat";
import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const deploy: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments } = hre; // we get the deployments and getNamedAccounts which are provided by hardhat-deploy.
  const { save, get } = deployments; // The deployments field itself contains the deploy function.

  const oldMinter = await get("HyperCertMinter");
  const newMinter = await ethers.getContractFactory("HyperCertMinter");
  const updatedMinter = await upgrades.upgradeProxy(oldMinter.address, newMinter);

  const artifact = await deployments.getExtendedArtifact("HyperCertMinter");
  const proxyDeployments = {
    address: updatedMinter.address,
    ...artifact,
  };

  await save("HyperCertMinter", proxyDeployments);
  console.log("Updated HyperCertMinter");
};

export default deploy;
deploy.tags = ["minter", "updateMinter"];
deploy.dependencies = ["HyperCertMinter"];
