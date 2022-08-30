import { ethers, upgrades } from "hardhat";
import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const deploy: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments } = hre; // we get the deployments and getNamedAccounts which are provided by hardhat-deploy.
  const { save, get } = deployments; // The deployments field itself contains the deploy function.

  const prev = await get("HypercertMinterV0");
  if (!prev) {
    console.log("Deployment v0 does not exists");
    return undefined;
  }

  const HypercertMinterV1Factory = await ethers.getContractFactory("HypercertMinterV1");

  await upgrades.validateUpgrade(prev.address, HypercertMinterV1Factory, { kind: "uups" });

  const upgrade = await upgrades.upgradeProxy(prev, HypercertMinterV1Factory);

  console.log("Address HypercertMinter V1: " + upgrade.address);

  const artifact = await deployments.getExtendedArtifact("HypercertMinterV1");
  const upgradeDeployments = {
    address: upgrade.address,
    ...artifact,
  };

  await save("HypercertMinterV1", upgradeDeployments);
};

export default deploy;
deploy.tags = ["local", "staging"];
