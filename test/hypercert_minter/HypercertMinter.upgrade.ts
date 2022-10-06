import { expect } from "chai";
import { ethers, getNamedAccounts, upgrades } from "hardhat";

import setupTest, { setupImpactScopes, setupRights, setupWorkScopes } from "../setup";
import { getClaimSlotID, getEncodedImpactClaim, newClaim, validateMetadata } from "../utils";
import { HyperCertMetadata, HyperCertMinter, HyperCertMinter_Upgrade, HyperCertSVG, UPGRADER_ROLE } from "../wellKnown";

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
    const claimID = await getClaimSlotID(claim);

    const HypercertSVGFactory = await ethers.getContractFactory(HyperCertSVG);
    const svg = await HypercertSVGFactory.deploy();

    const HypercertMetadataFactory = await ethers.getContractFactory(HyperCertMetadata);
    const metadata = await HypercertMetadataFactory.deploy(svg.address);

    const HypercertMinterFactory = await ethers.getContractFactory(HyperCertMinter);
    const UpgradeFactory = await ethers.getContractFactory(HyperCertMinter_Upgrade);

    const proxy = await upgrades.deployProxy(HypercertMinterFactory, [metadata.address], {
      kind: "uups",
    });
    expect(await proxy.version()).to.be.eq(0);

    const proxyWithUser = <HyperCertMinterUpgrade>await ethers.getContractAt(HyperCertMinter, proxy.address, user);
    await setupImpactScopes(proxyWithUser);
    await setupRights(proxyWithUser);
    await setupWorkScopes(proxyWithUser);
    await proxyWithUser.mint(user, data);

    const tokenURI = await proxyWithUser.tokenURI(1);

    console.log(tokenURI);

    const cid = "ipfs://mockedImpactClaim";
    validateMetadata(await proxyWithUser.tokenURI(1), cid);
    validateMetadata(await proxyWithUser.slotURI(claimID), cid);

    const upgrade = await upgrades.upgradeProxy(proxy, UpgradeFactory, {
      call: "updateVersion",
    });

    validateMetadata(await upgrade.tokenURI(1), cid);
    validateMetadata(await upgrade.slotURI(claimID), cid);

    const upgradeWithUser = await ethers.getContractAt(HyperCertMinter_Upgrade, upgrade.address, user);
    await expect(upgradeWithUser.split(1)).to.emit(upgrade, "Split").withArgs(1, [2]);
  });
}
