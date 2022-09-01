import { ethers, upgrades } from "hardhat";
import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

import { HypercertMinterV1 } from "../src/types";
import { HypercertMinter_V0, HypercertMinter_V1 } from "../test/wellKnown";

const deploy: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments } = hre; // we get the deployments and getNamedAccounts which are provided by hardhat-deploy.
  const { save, get } = deployments; // The deployments field itself contains the deploy function.

  try {
    await get(HypercertMinter_V0);
  } catch {
    console.log("Deployment v0 does not exists");
    return undefined;
  }

  try {
    const upgrade = await get(HypercertMinter_V1);
    if (upgrade) {
      console.log("Deployment v1 already exists");
      return undefined;
    }
  } catch {
    const prev = await get(HypercertMinter_V0);
    const HypercertMinterV1Factory = await ethers.getContractFactory(HypercertMinter_V1);

    await upgrades.validateUpgrade(prev.address, HypercertMinterV1Factory, { kind: "uups" });

    const upgrade = <HypercertMinterV1>await upgrades.upgradeProxy(prev, HypercertMinterV1Factory);

    console.log("Deployed upgrade HypercertMinter V1: " + upgrade.address);

    await upgrade.updateVersion();

    const artifact = await deployments.getExtendedArtifact(HypercertMinter_V1);
    const upgradeDeployments = {
      address: upgrade.address,
      ...artifact,
    };

    await save(HypercertMinter_V1, upgradeDeployments);
  }
};

export default deploy;
deploy.tags = ["local", "staging"];
