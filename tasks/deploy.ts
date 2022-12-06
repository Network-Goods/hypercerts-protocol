import { task } from "hardhat/config";

task("deploy", "Deploy contracts").setAction(async ({}, { ethers, upgrades }) => {
  const HypercertMinter = await ethers.getContractFactory("HypercertMinter");
  const hypercertMinter = await upgrades.deployProxy(HypercertMinter, [], {
    kind: "uups",
    unsafeAllow: ["constructor"],
  });
  await hypercertMinter.deployed();
  console.log(`HypercertMinter is deployed to proxy address: ${hypercertMinter.address}`);
});
