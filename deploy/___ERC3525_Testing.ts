import { ethers, upgrades } from "hardhat";
import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const deploy: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments } = hre; // we get the deployments and getNamedAccounts which are provided by hardhat-deploy.
  const { save } = deployments; // The deployments field itself contains the deploy function.

  const ERC3525_Test = await ethers.getContractFactory("ERC3525_Testing");
  const proxy = await upgrades.deployProxy(ERC3525_Test, { kind: "uups" });
  console.log("Deployed ERC3525_Testing + Proxy: " + proxy.address);

  const artifact = await deployments.getExtendedArtifact("ERC3525_Testing");
  const proxyDeployments = {
    address: proxy.address,
    ...artifact,
  };

  await save("ERC3525_Testing", proxyDeployments);
};

export default deploy;
deploy.tags = ["local"];
