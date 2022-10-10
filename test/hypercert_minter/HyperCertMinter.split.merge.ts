import { expect } from "chai";
import { ethers } from "hardhat";

import setupTest from "../setup";
import { encodeClaim, getClaimSlotID, newClaim, validateMetadata } from "../utils";

// TODO looping fractions
export function shouldBehaveLikeHypercertMinterSplitAndMerge(): void {
  it("should allow fraction owner to split a cert into new fractions - 1-to-many", async function () {
    const { user, minter } = await setupTest();
    const claim = await newClaim();
    const data = encodeClaim(claim);
    const slot = await getClaimSlotID(claim);

    await minter.mint(user.address, data);

    await expect(user.minter.split(1, [50])).to.be.revertedWith("AlreadyMinted(1)");
    await expect(user.minter.split(1, [100, 50])).to.be.revertedWith("InvalidInput()");
    await expect(user.minter.split(1, [20, 50])).to.be.revertedWith("InvalidInput()");
    await expect(user.minter.split(2, [50, 30, 10, 5, 5])).to.be.revertedWith("NonExistentToken(2)");

    await expect(user.minter.split(1, [50, 30, 10, 5, 5]))
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

    expect(await minter.ownerOf(1)).to.be.eq(user.address);
    expect(await minter.ownerOf(2)).to.be.eq(user.address);
    expect(await minter.ownerOf(3)).to.be.eq(user.address);
    expect(await minter.ownerOf(4)).to.be.eq(user.address);
    expect(await minter.ownerOf(5)).to.be.eq(user.address);

    expect(await minter.slotOf(1)).to.be.eq(slot);
    expect(await minter.slotOf(2)).to.be.eq(slot);
    expect(await minter.slotOf(3)).to.be.eq(slot);
    expect(await minter.slotOf(4)).to.be.eq(slot);
    expect(await minter.slotOf(5)).to.be.eq(slot);

    //TODO tokenSupply
    // expect(await minter.tokenSupplyInSlot(slot)).to.be.eq(5);

    expect(await minter["balanceOf(uint256)"](1)).to.be.eq("50");
    expect(await minter["balanceOf(uint256)"](2)).to.be.eq("30");
    expect(await minter["balanceOf(uint256)"](3)).to.be.eq("10");
    expect(await minter["balanceOf(uint256)"](4)).to.be.eq("5");
    expect(await minter["balanceOf(uint256)"](5)).to.be.eq("5");

    validateMetadata(await minter.tokenURI(1), claim);
    validateMetadata(await minter.tokenURI(2), claim);
    validateMetadata(await minter.tokenURI(3), claim);
    validateMetadata(await minter.tokenURI(4), claim);
    validateMetadata(await minter.tokenURI(5), claim);
  });

  it("should allow fraction owner to merge a cert fraction into an existing fraction", async function () {
    const { user, minter } = await setupTest();
    const claim = await newClaim({ fractions: [20, 30, 50] });
    const data = encodeClaim(claim);
    const slot = await getClaimSlotID(claim);

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
    expect(await minter.tokenSupplyInSlot(slot)).to.be.eq(2); // <-- 3
  });
}
