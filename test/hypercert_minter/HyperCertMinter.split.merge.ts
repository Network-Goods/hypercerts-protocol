import { expect } from "chai";
import { ethers } from "hardhat";

import setupTest from "../setup";
import { encodeClaim, newClaim, subScopeKeysForValues, validateMetadata } from "../utils";
import { ImpactScopes } from "../wellKnown";

export function shouldBehaveLikeHypercertMinterSplitAndMerge(): void {
  it("should allow fraction owner to split a cert into new fractions - 1-to-many", async function () {
    const { user, minter } = await setupTest();
    const claim = await newClaim();
    const data = encodeClaim(claim);
    const slot = 1;

    await minter.mint(user.address, data);

    await expect(user.minter.split(1, [50])).to.be.revertedWith("AlreadyMinted(1)");
    await expect(user.minter.split(1, [100, 50])).to.be.revertedWith("InvalidInput()");
    await expect(user.minter.split(1, [20, 50])).to.be.revertedWith("InvalidInput()");
    const fractions4 = [50, 30, 10, 5, 5];
    await expect(user.minter.split(2, fractions4)).to.be.revertedWith("NonExistentToken(2)");

    await expect(user.minter.split(1, fractions4))
      .to.emit(minter, "Transfer")
      .withArgs(ethers.constants.AddressZero, user.address, 2)
      .to.emit(minter, "SlotChanged")
      .withArgs(2, 0, slot)
      .to.emit(minter, "Transfer")
      .withArgs(ethers.constants.AddressZero, user.address, 3)
      .to.emit(minter, "SlotChanged")
      .withArgs(3, 0, slot)
      .to.emit(minter, "Transfer")
      .withArgs(ethers.constants.AddressZero, user.address, 4)
      .to.emit(minter, "SlotChanged")
      .withArgs(4, 0, slot)
      .to.emit(minter, "Transfer")
      .withArgs(ethers.constants.AddressZero, user.address, 5)
      .to.emit(minter, "SlotChanged")
      .withArgs(5, 0, slot);

    const claimSubbed = subScopeKeysForValues(claim, ImpactScopes);
    for (let i = 1; i <= fractions4.length; i++) {
      expect(await minter.ownerOf(i)).to.be.eq(user.address);
      expect(await minter.slotOf(i)).to.be.eq(slot);
      const units = fractions4[i - 1];
      expect(await minter["balanceOf(uint256)"](i)).to.be.eq(units);
      await validateMetadata(await minter.tokenURI(i), claimSubbed, units);
    }

    //TODO tokenSupply
    expect(await minter.tokenSupplyInSlot(slot)).to.be.eq(5);
  });

  it("should allow fraction owner to merge a cert fraction into an existing fraction", async function () {
    const { user, minter } = await setupTest();
    const claim = await newClaim({ fractions: [20, 30, 50] });
    const data = encodeClaim(claim);
    const slot = 1;

    await minter.mint(user.address, data);

    expect(await minter["balanceOf(uint256)"](1)).to.be.eq("20");
    expect(await minter["balanceOf(uint256)"](2)).to.be.eq("30");
    expect(await minter["balanceOf(uint256)"](3)).to.be.eq("50");
    expect(await minter.tokenSupplyInSlot(slot)).to.be.eq(3);

    await expect(user.minter.merge([1, 2]))
      .to.emit(minter, "TransferValue")
      .withArgs(1, 2, 20);

    await expect(minter["balanceOf(uint256)"](1)).to.be.revertedWith("NonExistentToken");
    expect(await minter["balanceOf(uint256)"](2)).to.be.eq("50");
    expect(await minter["balanceOf(uint256)"](3)).to.be.eq("50");
    expect(await minter.tokenSupplyInSlot(slot)).to.be.eq(2);
  });

  it("doesnt decrease total supply after nfts have been merged", async function () {
    const { user, minter, anon } = await setupTest();
    const claim = await newClaim({ fractions: [10] });
    const data = encodeClaim(claim);

    await minter.mint(user.address, data);
    await user.minter["transferFrom(uint256,address,uint256)"](1, anon.address, 5);
    expect(await minter["balanceOf(address)"](user.address)).to.be.equal(1);
    expect(await minter["balanceOf(address)"](anon.address)).to.be.equal(1);
    expect(await minter.totalSupply()).to.be.equal(2);

    await anon.minter["safeTransferFrom(address,address,uint256)"](anon.address, user.address, 2);
    await user.minter.merge([2, 1]);
    expect(await minter["balanceOf(address)"](user.address)).to.be.equal(1);
    expect(await minter["balanceOf(address)"](anon.address)).to.be.equal(0);
    expect(await minter["balanceOf(uint256)"](1)).to.be.equal(10);

    //fails: totalSupply is still 2
    expect(await minter.totalSupply()).to.be.equal(1);
  });
}
