import { expect } from "chai";
import { ethers } from "hardhat";

import setupTest from "../setup";
import { getEncodedImpactClaim } from "../utils";

export function shouldBehaveLikeHypercertMinterBurning(): void {
  it("owner can burn a token", async function () {
    const { deployer, minter } = await setupTest();
    const data = await getEncodedImpactClaim();

    // Supply 1, single user/id
    await expect(deployer.minter.mint(deployer.address, data))
      .to.emit(minter, "Transfer")
      .withArgs(ethers.constants.AddressZero, deployer.address, 0);
    await expect(deployer.minter.burn(0))
      .to.emit(minter, "Transfer")
      .withArgs(deployer.address, ethers.constants.AddressZero, 0);
    expect(await deployer.minter["balanceOf(address)"](deployer.address)).to.equal(0);
  });

  it("user cannot burn another's token", async function () {
    const { deployer, user, minter } = await setupTest();
    const data = await getEncodedImpactClaim();

    // Supply 1, multiple users/ids
    await expect(deployer.minter.mint(deployer.address, data))
      .to.emit(minter, "Transfer")
      .withArgs(ethers.constants.AddressZero, deployer.address, 0);
    await expect(user.minter.burn(0)).to.be.revertedWith("ERC721: caller is not token owner nor approved");
  });
}
