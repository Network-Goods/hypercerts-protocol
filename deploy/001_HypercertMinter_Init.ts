import { ethers, upgrades } from "hardhat";
import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const deploy: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments } = hre; // we get the deployments and getNamedAccounts which are provided by hardhat-deploy.
  const { save, get } = deployments; // The deployments field itself contains the deploy function.

  try {
    const exists = await get("HypercertMinter");
    if (exists && hre.network.name !== "hardhat") {
      console.log("Already deployed HypercertMinter");
    }
  } catch {
    const HypercertMetadata = await get("HypercertMetadata");

    const HypercertMinter = await ethers.getContractFactory("HypercertMinter");
    const proxy = await upgrades.deployProxy(HypercertMinter, [HypercertMetadata.address], {
      kind: "uups",
    });
    console.log("Deployed HypercertMinter + Proxy: " + proxy.address);

    const artifact = await deployments.getExtendedArtifact("HypercertMinter");
    const proxyDeployments = {
      address: proxy.address,
      ...artifact,
    };

    await save("HypercertMinter", proxyDeployments);
  }
};

export default deploy;
deploy.tags = ["local", "staging"];
deploy.dependencies = ["HypercertMetadata"];
