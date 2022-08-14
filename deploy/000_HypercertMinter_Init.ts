import { ethers, upgrades } from "hardhat";
import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const deploy: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments } = hre; // we get the deployments and getNamedAccounts which are provided by hardhat-deploy.
  const { save } = deployments; // The deployments field itself contains the deploy function.

  const HypercertMinter = await ethers.getContractFactory("HypercertMinterV0");
  const proxy = await upgrades.deployProxy(HypercertMinter, { kind: "uups" });
  console.log("Address HypercertMinter Proxy: " + proxy.address);

  const impl = await upgrades.upgradeProxy(proxy, HypercertMinter);
  console.log("Deploy HypercertMinter Impl:" + impl.address);

  const artifact = await deployments.getExtendedArtifact("HypercertMinterV0");
  const proxyDeployments = {
    address: proxy.address,
    ...artifact,
  };

  await save("HypercertMinterV0", proxyDeployments);
};

export default deploy;
deploy.tags = ["local", "staging"];
