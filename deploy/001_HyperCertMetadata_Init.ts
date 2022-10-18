import { ethers, upgrades } from "hardhat";
import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const deploy: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments } = hre; // we get the deployments and getNamedAccounts which are provided by hardhat-deploy.
  const { save, get } = deployments; // The deployments field itself contains the deploy function.

  try {
    const exists = await get("HyperCertMetadata");
    if (exists && hre.network.name !== "hardhat") {
      console.log("Already deployed HyperCertMetadata");
    }
  } catch {
    const HyperCertSVG = await get("HyperCertSVG");

    const HyperCertMetadata = await ethers.getContractFactory("HyperCertMetadata");
    const proxy = await upgrades.deployProxy(HyperCertMetadata, [HyperCertSVG.address], {
      kind: "uups",
    });
    console.log("Deployed HyperCertMetadata + Proxy: " + proxy.address);

    const artifact = await deployments.getExtendedArtifact("HyperCertMetadata");
    const proxyDeployments = {
      address: proxy.address,
      ...artifact,
    };

    await save("HyperCertMetadata", proxyDeployments);
  }
};

export default deploy;
deploy.tags = ["minter", "local", "staging"];
deploy.dependencies = ["HyperCertSVG"];
