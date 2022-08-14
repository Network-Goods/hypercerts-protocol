import { deployments } from "hardhat";

const setupTest = deployments.createFixture(async ({ deployments, getNamedAccounts, ethers }) => {
  await deployments.fixture(); // ensure you start from a fresh deployments
  const { deployer, user, anon } = await getNamedAccounts();

  // Contracts
  const minter = await ethers.getContract("HypercertMinterV0");

  // Account config
  const setupAddress = async (address: string) => {
    return {
      address: address,
      minter: await ethers.getContract("HypercertMinterV0", address),
    };
  };

  // Struct
  return {
    minter,
    deployer: await setupAddress(deployer),
    user: await setupAddress(user),
    anon: await setupAddress(anon),
  };
});

export default setupTest;
