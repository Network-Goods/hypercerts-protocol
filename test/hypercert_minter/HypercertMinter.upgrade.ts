import { expect } from "chai";
import { ethers, getNamedAccounts, upgrades } from "hardhat";

import { HypercertMinterUpgrade, HypercertMinterV0 } from "../../src/types";
import setupTest, { setupImpactScopes, setupRights, setupWorkScopes } from "../setup";
import { getClaimSlotID, getEncodedImpactClaim, newClaim } from "../utils";
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
    const HypercertMetadataFactory = await ethers.getContractFactory("HypercertMetadata");
    const HypercertMetadata = await HypercertMetadataFactory.deploy();
    const HypercertMinterV0Factory = await ethers.getContractFactory(HypercertMinter_V0, {
      libraries: { HypercertMetadata: HypercertMetadata.address },
    });

    const UpgradeFactory = await ethers.getContractFactory(HypercertMinter_Upgrade, {
      libraries: { HypercertMetadata: HypercertMetadata.address },
    });

    const proxy = await upgrades.deployProxy(HypercertMinterV0Factory, {
      kind: "uups",
      unsafeAllow: ["external-library-linking"],
    });

    expect(await proxy.version()).to.be.eq(0);

    const upgrade = await upgrades.upgradeProxy(proxy, UpgradeFactory, {
      call: "updateVersion",
      unsafeAllow: ["external-library-linking"],
    });

    expect(await proxy.version()).to.be.eq(1);
    expect(await upgrade.version()).to.be.eq(1);
  });

  it("retains state of minted tokens", async function () {
    const { user } = await getNamedAccounts();
    const claim = await newClaim();
    const data = await getEncodedImpactClaim(claim);
    const claimID = await getClaimSlotID(claim);
    const HypercertMetadataFactory = await ethers.getContractFactory("HypercertMetadata");
    const HypercertMetadata = await HypercertMetadataFactory.deploy();
    const HypercertMinterV0Factory = await ethers.getContractFactory(HypercertMinter_V0, {
      libraries: { HypercertMetadata: HypercertMetadata.address },
    });
    const UpgradeFactory = await ethers.getContractFactory(HypercertMinter_Upgrade, {
      libraries: { HypercertMetadata: HypercertMetadata.address },
    });

    const proxy = await upgrades.deployProxy(HypercertMinterV0Factory, {
      kind: "uups",
      unsafeAllow: ["external-library-linking"],
    });
    expect(await proxy.version()).to.be.eq(0);

    const proxyWithUser = <HypercertMinterV0>await ethers.getContractAt(HypercertMinter_V0, proxy.address, user);
    await setupImpactScopes(proxyWithUser);
    await setupRights(proxyWithUser);
    await setupWorkScopes(proxyWithUser);
    await proxyWithUser.mint(user, data);

    const tokenURI = await proxyWithUser.tokenURI(1);

    console.log(tokenURI);

    expect(await proxyWithUser.tokenURI(1))
      .to.include("data:application/json;")
      .to.include("ipfs://mockedImpactClaim");
    expect(await proxyWithUser.slotURI(claimID))
      .to.include("data:application/json;")
      .to.include("ipfs://mockedImpactClaim");

    const upgrade = await upgrades.upgradeProxy(proxy, UpgradeFactory, {
      call: "updateVersion",
      unsafeAllow: ["external-library-linking"],
    });

    expect(await upgrade.tokenURI(1))
      .to.include("data:application/json;")
      .to.include("ipfs://mockedImpactClaim");
    expect(await upgrade.slotURI(claimID))
      .to.include("data:application/json;")
      .to.include("ipfs://mockedImpactClaim");

    const upgradeWithUser = <HypercertMinterUpgrade>(
      await ethers.getContractAt(HypercertMinter_Upgrade, upgrade.address, user)
    );
    await expect(upgradeWithUser.split(1)).to.emit(upgrade, "Split").withArgs(1, [2]);
  });
}
