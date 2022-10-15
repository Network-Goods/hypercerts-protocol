import { ethers, upgrades } from "hardhat";
import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const deploy: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments } = hre; // we get the deployments and getNamedAccounts which are provided by hardhat-deploy.
  const { save, get } = deployments; // The deployments field itself contains the deploy function.

  try {
    const exists = await get("HyperCertSVG");
    if (exists && hre.network.name !== "hardhat") {
      console.log("Already deployed HyperCertSVG");
    }
  } catch {
    const HyperCertSVG = await ethers.getContractFactory("HyperCertSVG");
    const proxy = await upgrades.deployProxy(HyperCertSVG, [], {
      kind: "uups",
    });
    console.log("Deployed HyperCertSVG + proxy: " + proxy.address);

    const artifact = await deployments.getExtendedArtifact("HyperCertSVG");
    const proxyDeployments = {
      address: proxy.address,
      ...artifact,
    };

    await save("HyperCertSVG", proxyDeployments);
  }
};

export default deploy;
deploy.tags = ["minter", "local", "staging", "svg"];
