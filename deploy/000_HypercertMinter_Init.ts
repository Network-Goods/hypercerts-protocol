import { ethers, upgrades } from "hardhat";
import { DeployFunction } from "hardhat-deploy/types";

const HYPERCERT_MINTER = "HypercertMinterV0";

const deploy: DeployFunction = async function ({ getNamedAccounts, deployments }) {
  const { deploy } = deployments; // The deployments field itself contains the deploy function.
  const { deployer } = await getNamedAccounts();

  const HypercertMinter = await ethers.getContractFactory(HYPERCERT_MINTER);
  const proxy = await upgrades.deployProxy(HypercertMinter, { kind: "uups" });
  console.log("Address HypercertMinter Proxy: " + proxy.address);

  await deploy(HYPERCERT_MINTER, {
    from: deployer,
    log: true,
  });
};

export default deploy;
deploy.tags = [HYPERCERT_MINTER, "local", "staging"];
