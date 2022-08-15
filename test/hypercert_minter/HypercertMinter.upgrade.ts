import { expect } from "chai";
import { ethers, getNamedAccounts, upgrades } from "hardhat";

import setupTest from "../setup";

export function shouldBehaveLikeHypercertMinterUpgrade(): void {
  it("supports upgrader role", async function () {
    it("Support admin role", async function () {
      const { user, deployer, minter } = await setupTest();

      const UPGRADER_ROLE = ethers.utils.id("UPGRADER_ROLE");
      expect(await minter.hasRole(UPGRADER_ROLE, deployer.address)).to.be.true;
      expect(await minter.hasRole(UPGRADER_ROLE, user.address)).to.be.false;

      await expect(deployer.minter.grantRole(UPGRADER_ROLE, user.address)).to.be.revertedWith(
        `AccessControl: account ${deployer.address.toLowerCase()} is missing role ${UPGRADER_ROLE}`,
      );

      await expect(deployer.minter.grantRole(UPGRADER_ROLE, user.address))
        .to.emit(minter, "RoleGranted")
        .withArgs(UPGRADER_ROLE, user.address, deployer.address);
    });
  });

  //TODO automated update logic
  it("Updates version number on update", async function () {
    const HypercertMinterV0Factory = await ethers.getContractFactory("HypercertMinterV0");

    const UpgradeFactory = await ethers.getContractFactory("HypercertMinter_Upgrade");

    const proxy = await upgrades.deployProxy(HypercertMinterV0Factory, { kind: "uups" });

    expect(await proxy.version()).to.be.eq(0);

    const upgrade = await upgrades.upgradeProxy(proxy, UpgradeFactory);

    expect(await proxy.version()).to.be.eq(1);
    expect(await upgrade.version()).to.be.eq(1);
  });

  it("Retains state of minted tokens", async function () {
    const { user } = await getNamedAccounts();
    const HypercertMinterV0Factory = await ethers.getContractFactory("HypercertMinterV0");
    const UpgradeFactory = await ethers.getContractFactory("HypercertMinter_Upgrade");

    const proxy = await upgrades.deployProxy(HypercertMinterV0Factory, { kind: "uups" });
    expect(await proxy.version()).to.be.eq(0);

    const proxyWithUser = await ethers.getContractAt("HypercertMinterV0", proxy.address, user);
    await proxyWithUser.mint(user, 1, 1, ethers.utils.toUtf8Bytes("ipfs://test"));

    expect(await proxyWithUser.uri(1)).to.be.eq("ipfs://test");

    const upgrade = await upgrades.upgradeProxy(proxy, UpgradeFactory);

    await expect(
      proxyWithUser.mint(user, 1, 1, ethers.utils.toUtf8Bytes("ipfs://test-persistance")),
    ).to.be.revertedWith("Mint: token with provided ID already exists");

    expect(await upgrade.uri(1)).to.be.eq("ipfs://test");

    const upgradeWithUser = await ethers.getContractAt("HypercertMinter_Upgrade", upgrade.address, user);
    await expect(upgradeWithUser.split(1)).to.emit(upgrade, "Split").withArgs(1, [2]);
  });
}
