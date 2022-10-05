import { expect } from "chai";
import { ethers, getNamedAccounts, upgrades } from "hardhat";

import setupTest, { setupImpactScopes, setupRights, setupWorkScopes } from "../setup";
import { getClaimSlotID, getEncodedImpactClaim, newClaim } from "../utils";
import { HypercertMetadata, HypercertMinter, HypercertMinter_Upgrade, HypercertSVG, UPGRADER_ROLE } from "../wellKnown";

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
    const HypercertMinterV0Factory = await ethers.getContractFactory(HypercertMinter);
    const { anon } = await getNamedAccounts();

    const UpgradeFactory = await ethers.getContractFactory(HypercertMinter_Upgrade);

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
    const claimID = await getClaimSlotID(claim);

    const HypercertSVGFactory = await ethers.getContractFactory(HypercertSVG);
    const svg = await HypercertSVGFactory.deploy();

    const HypercertMetadataFactory = await ethers.getContractFactory(HypercertMetadata);
    const metadata = await HypercertMetadataFactory.deploy(svg.address);

    const HypercertMinterFactory = await ethers.getContractFactory(HypercertMinter);
    const UpgradeFactory = await ethers.getContractFactory(HypercertMinter_Upgrade);

    const proxy = await upgrades.deployProxy(HypercertMinterFactory, [metadata.address], {
      kind: "uups",
    });
    expect(await proxy.version()).to.be.eq(0);

    const proxyWithUser = await ethers.getContractAt(HypercertMinter, proxy.address, user);
    await setupImpactScopes(proxyWithUser);
    await setupRights(proxyWithUser);
    await setupWorkScopes(proxyWithUser);
    await proxyWithUser.mint(user, data);

    expect(await proxyWithUser.tokenURI(1))
      .to.include("data:application/json;")
      .to.include("ipfs://mockedImpactClaim");
    expect(await proxyWithUser.slotURI(claimID))
      .to.include("data:application/json;")
      .to.include("ipfs://mockedImpactClaim");

    const upgrade = await upgrades.upgradeProxy(proxy, UpgradeFactory, {
      call: "updateVersion",
    });

    expect(await upgrade.tokenURI(1))
      .to.include("data:application/json;")
      .to.include("ipfs://mockedImpactClaim");
    expect(await upgrade.slotURI(claimID))
      .to.include("data:application/json;")
      .to.include("ipfs://mockedImpactClaim");

    const upgradeWithUser = await ethers.getContractAt(HypercertMinter_Upgrade, upgrade.address, user);
    await expect(upgradeWithUser.split(1)).to.emit(upgrade, "Split").withArgs(1, [2]);
  });
}
