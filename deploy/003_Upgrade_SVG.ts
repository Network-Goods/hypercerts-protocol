import { ethers, upgrades } from "hardhat";
import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const deploy: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments } = hre; // we get the deployments and getNamedAccounts which are provided by hardhat-deploy.
  const { save, get } = deployments; // The deployments field itself contains the deploy function.

  const oldSVG = await get("HyperCertSVG");
  const newSVG = await ethers.getContractFactory("HyperCertSVG");
  const updatedSVG = await upgrades.upgradeProxy(oldSVG.address, newSVG);

  const artifact = await deployments.getExtendedArtifact("HyperCertSVG");
  const proxyDeployments = {
    address: updatedSVG.address,
    ...artifact,
  };

  await save("HyperCertSVG", proxyDeployments);
  console.log("Updated HyperCertSVG");
};

export default deploy;
deploy.tags = ["local", "staging"];
deploy.dependencies = ["HyperCertSVG"];
