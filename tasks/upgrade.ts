import { task } from "hardhat/config";

//TODO parameterize proxy contract address
task("upgrade", "Upgrade implementation contract and verify").setAction(async ({}, { ethers, upgrades }) => {
  const PROXY_ADDRESS = "0xcC08266250930E98256182734913Bf1B36102072";
  const HypercertMinter = await ethers.getContractFactory("HypercertMinter");

  // Validate (redundant?)
  console.log("Validating upgrade..");
  await upgrades.validateUpgrade(PROXY_ADDRESS, HypercertMinter).then(() => console.log("Valid upgrade. Deploying.."));

  // Upgrade
  const hypercertMinterUpgrade = await upgrades.upgradeProxy(PROXY_ADDRESS, HypercertMinter, {
    kind: "uups",
    unsafeAllow: ["constructor"],
  });
  await hypercertMinterUpgrade.deployed();
  console.log(`HypercertMinter at proxy address ${hypercertMinterUpgrade.address} was upgraded`);

  try {
    const code = await hypercertMinterUpgrade.instance?.provider.getCode(hypercertMinterUpgrade.address);
    if (code === "0x") {
      console.log(`${hypercertMinterUpgrade.name} contract upgrade has not completed. waiting to verify...`);
      await hypercertMinterUpgrade.instance?.deployed();
    }
    await hre.run("verify:verify", {
      address: hypercertMinterUpgrade.address,
    });
  } catch ({ message }) {
    if ((message as string).includes("Reason: Already Verified")) {
      console.log("Reason: Already Verified");
    }
    console.error(message);
  }
});
