import { expect } from "chai";
import { ethers } from "hardhat";

import setupTest from "../setup";
import { encodeClaim, getEncodedImpactClaim, newClaim } from "../utils";

export function shouldBehaveLikeHypercertMinterBurning(): void {
  it("allows burning when the creator owns the full slot", async function () {
    const { deployer, minter } = await setupTest();
    const claim = await newClaim();
    const data = encodeClaim(claim);
    const tokenId = 1;

    await expect(deployer.minter.mint(deployer.address, data)).to.emit(minter, "ImpactClaimed");

    expect(await minter["balanceOf(address)"](deployer.address)).to.equal(1);
    expect(await minter["balanceOf(uint256)"](tokenId)).to.equal(100);
    expect(await minter.ownerOf(tokenId)).to.be.eq(deployer.address);
    expect(await minter.slotOf(1)).to.be.eq(1);
    expect(await minter.tokenSupplyInSlot(1)).to.be.eq(1);
    expect(await minter.tokenURI(1)).to.include("data:application/json;");
    expect(await minter.slotURI(1)).to.include("data:application/json;");

    await expect(deployer.minter.burn(tokenId))
      .to.emit(minter, "Transfer")
      .withArgs(deployer.address, ethers.constants.AddressZero, tokenId)
      .to.emit(minter, "TransferValue")
      .withArgs(tokenId, 0, 100)
      .to.emit(minter, "SlotChanged")
      .withArgs(tokenId, 1, 0);

    expect(await deployer.minter["balanceOf(address)"](deployer.address)).to.equal(0);
    await expect(minter["balanceOf(uint256)"](tokenId)).to.be.revertedWith(
      "ERC3525: balance query for nonexistent token",
    );
    await expect(minter.ownerOf(tokenId)).to.be.revertedWith("ERC721: invalid token ID");
    await expect(minter.slotOf(tokenId)).to.be.revertedWith("ERC3525: slot query for nonexistent token");
    expect(await minter.tokenSupplyInSlot(1)).to.be.eq(0);
    await expect(minter.tokenURI(tokenId)).to.be.revertedWith("ERC721: invalid token ID");
    await expect(minter.slotURI(tokenId)).to.be.revertedWith("RC3525: slot query for nonexistent slot");
  });

  it("prevents burning when the creator doesn't own the full slot", async function () {
    const { deployer, minter, user } = await setupTest();
    const claim = await newClaim({ fractions: [50, 50] });
    const data = encodeClaim(claim);

    await expect(deployer.minter.mint(deployer.address, data)).to.emit(minter, "ImpactClaimed");
    expect(await minter.tokenSupplyInSlot(1)).to.be.eq(2);
    expect(await minter["balanceOf(address)"](deployer.address)).to.equal(2);

    await expect(deployer.minter["transferFrom(address,address,uint256)"](deployer.address, user.address, 1)).to.emit(
      minter,
      "Transfer",
    );

    expect(await minter.tokenSupplyInSlot(1)).to.be.eq(2);
    expect(await minter["balanceOf(address)"](deployer.address)).to.equal(1);
    expect(await minter["balanceOf(address)"](user.address)).to.equal(1);

    await expect(deployer.minter.burn(1)).to.be.revertedWith("Hypercert: cannot burn partial hypercert");

    expect(await minter.tokenSupplyInSlot(1)).to.be.eq(2);
    expect(await minter["balanceOf(address)"](deployer.address)).to.equal(1);
    expect(await minter["balanceOf(address)"](user.address)).to.equal(1);
  });

  it("prevents burning when the owner isn't the creator", async function () {
    const { deployer, minter, user, anon } = await setupTest();
    const claim = await newClaim({ fractions: [50, 50] });
    const data = encodeClaim(claim);

    await expect(deployer.minter.mint(anon.address, data)).to.emit(minter, "ImpactClaimed");
    expect(await minter.tokenSupplyInSlot(1)).to.be.eq(2);
    expect(await minter["balanceOf(address)"](deployer.address)).to.equal(0);
    expect(await minter["balanceOf(address)"](anon.address)).to.equal(2);

    await expect(anon.minter.burn(1)).to.be.revertedWith("Hypercert: only creator can burn claim");
    await expect(deployer.minter.burn(1)).to.be.revertedWith("Hypercert: owner isn't creator");

    expect(await minter.tokenSupplyInSlot(1)).to.be.eq(2);
    expect(await minter["balanceOf(address)"](deployer.address)).to.equal(0);
    expect(await minter["balanceOf(address)"](anon.address)).to.equal(2);
  });
}
