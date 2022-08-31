import { expect } from "chai";
import { ethers, getNamedAccounts, upgrades } from "hardhat";

import { HypercertMinterV0 } from "../../src/types";
import setupTest, { setupImpactScopes, setupRights, setupWorkScopes } from "../setup";
import { getEncodedImpactClaim } from "../utils";
import { Contracts } from "../wellKnown";

const { HypercertMinter, HypercertMinterUpgrade } = Contracts;

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
  it("updates version number on update", async function () {
    const HypercertMinterV0Factory = await ethers.getContractFactory(HypercertMinter);

    const UpgradeFactory = await ethers.getContractFactory(HypercertMinterUpgrade);

    const proxy = await upgrades.deployProxy(HypercertMinterV0Factory, { kind: "uups" });

    expect(await proxy.version()).to.be.eq(0);

    const upgrade = await upgrades.upgradeProxy(proxy, UpgradeFactory);

    expect(await proxy.version()).to.be.eq(1);
    expect(await upgrade.version()).to.be.eq(1);
  });

  it("retains state of minted tokens", async function () {
    const { user } = await getNamedAccounts();
    const data = await getEncodedImpactClaim();
    const HypercertMinterV0Factory = await ethers.getContractFactory(HypercertMinter);
    const UpgradeFactory = await ethers.getContractFactory(HypercertMinterUpgrade);

    const proxy = await upgrades.deployProxy(HypercertMinterV0Factory, { kind: "uups" });
    expect(await proxy.version()).to.be.eq(0);

    const proxyWithUser = <HypercertMinterV0>await ethers.getContractAt(HypercertMinter, proxy.address, proxy.signer);
    await setupImpactScopes(proxyWithUser);
    await setupRights(proxyWithUser);
    await setupWorkScopes(proxyWithUser);
    await proxyWithUser.mint(user, 1, data);

    expect(await proxyWithUser.uri(0)).to.be.eq("ipfs://mockedImpactClaim");

    const upgrade = await upgrades.upgradeProxy(proxy, UpgradeFactory);

    expect(await upgrade.uri(0)).to.be.eq("ipfs://mockedImpactClaim");

    const upgradeWithUser = await ethers.getContractAt(HypercertMinterUpgrade, upgrade.address, upgrade.signer);
    await expect(upgradeWithUser.split(0)).to.emit(upgrade, "Split").withArgs(0, [1]);
  });
}
