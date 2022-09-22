import { expect } from "chai";
import { ethers } from "hardhat";

import setupTest from "../setup";
import { encodeClaim, getClaimHash, getEncodedImpactClaim, newClaim } from "../utils";

export function shouldBehaveLikeHypercertMinterBurning(): void {
  it("owner can burn a token", async function () {
    const { deployer, minter } = await setupTest();
    const claim = await newClaim();
    const data = encodeClaim(claim);
    const hash = await getClaimHash(claim);
    const tokenId = 1;
    const defaultValue = 10000;

    // Supply 1, single user/id
    await expect(deployer.minter.mint(deployer.address, data))
      .to.emit(minter, "Transfer")
      .withArgs(ethers.constants.AddressZero, deployer.address, tokenId);
    expect(await deployer.minter["balanceOf(address)"](deployer.address)).to.equal(1);
    expect(await deployer.minter.ownerOf(tokenId)).to.be.eq(deployer.address);
    expect(deployer.address).to.be.not.equal(ethers.constants.AddressZero);
    await expect(deployer.minter.burn(tokenId))
      .to.emit(minter, "Transfer")
      .withArgs(deployer.address, ethers.constants.AddressZero, tokenId)
      .to.emit(minter, "TransferValue")
      .withArgs(tokenId, 0, defaultValue)
      .to.emit(minter, "SlotChanged")
      .withArgs(tokenId, hash, 0);
    expect(await deployer.minter["balanceOf(address)"](deployer.address)).to.equal(0);
  });

  it("user cannot burn another's token", async function () {
    const { deployer, user, minter } = await setupTest();
    const data = await getEncodedImpactClaim();

    // Supply 1, multiple users/ids
    await expect(deployer.minter.mint(deployer.address, data))
      .to.emit(minter, "Transfer")
      .withArgs(ethers.constants.AddressZero, deployer.address, 1);
    await expect(user.minter.burn(1)).to.be.revertedWith("ERC721: caller is not token owner nor approved");
  });
}
