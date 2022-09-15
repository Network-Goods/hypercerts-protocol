import { expect } from "chai";
import { ethers, getNamedAccounts, upgrades } from "hardhat";

import { HypercertMinterUpgrade, HypercertMinterV0 } from "../../src/types";
import setupTest, { setupImpactScopes, setupRights, setupWorkScopes } from "../setup";
import { getEncodedImpactClaim } from "../utils";
import { HypercertMinter_Upgrade, HypercertMinter_V0, UPGRADER_ROLE } from "../wellKnown";

export function shouldBehaveLikeHypercertMinterUpgrade(): void {
  it("supports upgrader role", async function () {
    it("Support admin role", async function () {
      const { user, deployer, minter } = await setupTest();

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

  it("updates version number on update", async function () {
    const HypercertMinterV0Factory = await ethers.getContractFactory(HypercertMinter_V0);

    const UpgradeFactory = await ethers.getContractFactory(HypercertMinter_Upgrade);

    const proxy = await upgrades.deployProxy(HypercertMinterV0Factory, { kind: "uups" });

    expect(await proxy.version()).to.be.eq(0);

    const upgrade = await upgrades.upgradeProxy(proxy, UpgradeFactory, { call: "updateVersion" });

    expect(await proxy.version()).to.be.eq(1);
    expect(await upgrade.version()).to.be.eq(1);
  });

  it("retains state of minted tokens", async function () {
    const { user } = await getNamedAccounts();
    const data = await getEncodedImpactClaim();
    const HypercertMinterV0Factory = await ethers.getContractFactory(HypercertMinter_V0);
    const UpgradeFactory = await ethers.getContractFactory(HypercertMinter_Upgrade);

    const proxy = await upgrades.deployProxy(HypercertMinterV0Factory, { kind: "uups" });
    expect(await proxy.version()).to.be.eq(0);

    const proxyWithUser = <HypercertMinterV0>await ethers.getContractAt(HypercertMinter_V0, proxy.address, user);
    await setupImpactScopes(proxyWithUser);
    await setupRights(proxyWithUser);
    await setupWorkScopes(proxyWithUser);
    await proxyWithUser.mint(user, data);

    expect(await proxyWithUser.tokenURI(0)).to.be.eq("ipfs://mockedImpactClaim");

    const upgrade = await upgrades.upgradeProxy(proxy, UpgradeFactory, { call: "updateVersion" });

    expect(await upgrade.tokenURI(0)).to.be.eq("ipfs://mockedImpactClaim");

    const upgradeWithUser = <HypercertMinterUpgrade>(
      await ethers.getContractAt(HypercertMinter_Upgrade, upgrade.address, user)
    );
    await expect(upgradeWithUser.split(0)).to.emit(upgrade, "Split").withArgs(0, [1]);
  });
}
