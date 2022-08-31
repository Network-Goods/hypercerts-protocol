import { ethers, upgrades } from "hardhat";
import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const deploy: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments } = hre; // we get the deployments and getNamedAccounts which are provided by hardhat-deploy.
  const { save, get } = deployments; // The deployments field itself contains the deploy function.

  try {
    await get("HypercertMinterV0");
  } catch {
    console.log("Deployment v0 does not exists");
    return undefined;
  }

  try {
    const upgrade = await get("HypercertMinterV1");
    if (upgrade) {
      console.log("Deployment v1 already exists");
      return undefined;
    }
  } catch {
    const prev = await get("HypercertMinterV0");
    const HypercertMinterV1Factory = await ethers.getContractFactory("HypercertMinterV1");

    await upgrades.validateUpgrade(prev.address, HypercertMinterV1Factory, { kind: "uups" });

    const upgrade = await upgrades.upgradeProxy(prev, HypercertMinterV1Factory);

    console.log("Deployed upgrade HypercertMinter V1: " + upgrade.address);

    const artifact = await deployments.getExtendedArtifact("HypercertMinterV1");
    const upgradeDeployments = {
      address: upgrade.address,
      ...artifact,
    };

    await save("HypercertMinterV1", upgradeDeployments);
  }
};

export default deploy;
deploy.tags = ["local", "staging"];
