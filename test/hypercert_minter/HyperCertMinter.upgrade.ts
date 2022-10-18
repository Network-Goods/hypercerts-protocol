import { expect } from "chai";
import { ethers, getNamedAccounts, upgrades } from "hardhat";

import { HyperCertMinterUpgrade } from "../../src/types";
import setupTest, { setupImpactScopes, setupRights, setupTestMetadata, setupWorkScopes } from "../setup";
import { getEncodedImpactClaim, newClaim, subScopeKeysForValues, validateMetadata } from "../utils";
import { HyperCertMinter, HyperCertMinter_Upgrade, ImpactScopes, UPGRADER_ROLE } from "../wellKnown";

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
    const HypercertMinterV0Factory = await ethers.getContractFactory(HyperCertMinter);
    const { anon } = await getNamedAccounts();

    const UpgradeFactory = await ethers.getContractFactory(HyperCertMinter_Upgrade);

    const proxy = await upgrades.deployProxy(HypercertMinterV0Factory, [anon], {
      kind: "uups",
    });

    expect(await proxy.version()).to.be.eq(0);

    const upgrade = await upgrades.upgradeProxy(proxy, UpgradeFactory, {
      call: "updateVersion",
    });

    expect(await proxy.version()).to.be.eq(1);
    expect(await upgrade.version()).to.be.eq(1);
  });

  it("retains state of minted tokens", async function () {
    const { user } = await getNamedAccounts();
    const claim = await newClaim();
    const data = await getEncodedImpactClaim(claim);
    const { sft } = await setupTestMetadata();

    const HypercertMinterFactory = await ethers.getContractFactory(HyperCertMinter);
    const UpgradeFactory = await ethers.getContractFactory(HyperCertMinter_Upgrade);

    const proxy = await upgrades.deployProxy(HypercertMinterFactory, [sft.address], {
      kind: "uups",
    });
    expect(await proxy.version()).to.be.eq(0);

    const proxyWithUser = <HyperCertMinterUpgrade>await ethers.getContractAt(HyperCertMinter, proxy.address, user);
    await setupImpactScopes(proxyWithUser);
    await setupRights(proxyWithUser);
    await setupWorkScopes(proxyWithUser);
    await proxyWithUser.mint(user, data);
    const claimSubbed = subScopeKeysForValues(claim, ImpactScopes);
    await validateMetadata(await proxyWithUser.tokenURI(1), claimSubbed, claim.fractions[0]);
    await validateMetadata(await proxyWithUser.slotURI(1), claimSubbed);

    const upgrade = await upgrades.upgradeProxy(proxy, UpgradeFactory, {
      call: "updateVersion",
    });

    expect(await upgrade.mockedUpgradeFunction()).to.be.true;

    await validateMetadata(await upgrade.tokenURI(1), claimSubbed, claim.fractions[0]);
    await validateMetadata(await upgrade.slotURI(1), claimSubbed);

    const upgradeWithUser = await ethers.getContractAt(HyperCertMinter_Upgrade, upgrade.address, user);
    await expect(upgradeWithUser.split(1, [50, 50]))
      .to.emit(upgradeWithUser, "Transfer")
      .withArgs(ethers.constants.AddressZero, user, 2)
      .to.emit(upgradeWithUser, "SlotChanged")
      .withArgs(2, 0, 1);
  });
}
