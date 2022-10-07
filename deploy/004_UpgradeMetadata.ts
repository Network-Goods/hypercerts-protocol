import { ethers, upgrades } from "hardhat";
import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const deploy: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments } = hre; // we get the deployments and getNamedAccounts which are provided by hardhat-deploy.
  const { save, get } = deployments; // The deployments field itself contains the deploy function.

  const oldMetadata = await get("HyperCertMetadata");
  const newMetadata = await ethers.getContractFactory("HyperCertMetadata");
  const updatedMetadata = await upgrades.upgradeProxy(oldMetadata.address, newMetadata);

  const artifact = await deployments.getExtendedArtifact("HyperCertMetadata");
  const proxyDeployments = {
    address: updatedMetadata.address,
    ...artifact,
  };

  await save("HyperCertMetadata", proxyDeployments);
  console.log("Updated HyperCertMetadata");
};

export default deploy;
deploy.tags = ["local", "staging"];
deploy.dependencies = ["HyperCertMetadata"];
