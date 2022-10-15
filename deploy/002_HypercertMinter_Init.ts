import { ethers, upgrades } from "hardhat";
import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const deploy: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments } = hre; // we get the deployments and getNamedAccounts which are provided by hardhat-deploy.
  const { save, get } = deployments; // The deployments field itself contains the deploy function.

  try {
    const exists = await get("HyperCertMinter");
    if (exists && hre.network.name !== "hardhat") {
      console.log("Already deployed HyperCertMinter");
    }
  } catch {
    const HypercertMetadata = await get("HyperCertMetadata");

    const HypercertMinter = await ethers.getContractFactory("HyperCertMinter");
    const proxy = await upgrades.deployProxy(HypercertMinter, [HypercertMetadata.address], {
      kind: "uups",
    });
    console.log("Deployed HyperCertMinter + Proxy: " + proxy.address);

    const artifact = await deployments.getExtendedArtifact("HyperCertMinter");
    const proxyDeployments = {
      address: proxy.address,
      ...artifact,
    };

    await save("HyperCertMinter", proxyDeployments);
  }
};

export default deploy;
deploy.tags = ["minter", "local", "staging"];
deploy.dependencies = ["HyperCertMetadata"];
