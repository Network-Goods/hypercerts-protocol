import { expect } from "chai";
import { ethers } from "hardhat";

import setupTest from "../setup";
import { getEncodedImpactClaim } from "../utils";

// TODO looping fractions
export function shouldBehaveLikeHypercertMinterSplitAndMerge(): void {
  it.skip("should allow fraction owner to split a cert into to new fractions - 1-to-many", async function () {
    const { user, minter } = await setupTest();
    const data = await getEncodedImpactClaim();

    await minter.mint(user.address, data);

    await expect(user.minter.split(1, [50])).to.be.revertedWith("Hypercert: split requires more than one fraction");
    await expect(user.minter.split(1, [100, 50])).to.be.revertedWith(
      "Hypercert: sum of fractions higher than original value",
    );
    await expect(user.minter.split(1, [20, 50])).to.be.revertedWith(
      "Hypercert: sum of fractions lower than original value",
    );
    await expect(user.minter.split(2, [50, 30, 10, 5, 5])).to.be.revertedWith(
      "Hypercert: split requested for nonexistent token",
    );

    await expect(user.minter.split(1, [50, 30, 10, 5, 5]))
      .to.emit(minter, "Transfer")
      .withArgs(ethers.constants.AddressZero, user.address, 2)
      .to.emit(minter, "SlotChanged")
      .withArgs(2, 0, 1)
      .to.emit(minter, "Transfer")
      .withArgs(ethers.constants.AddressZero, user.address, 3)
      .to.emit(minter, "SlotChanged")
      .withArgs(3, 0, 1)
      .to.emit(minter, "Transfer")
      .withArgs(ethers.constants.AddressZero, user.address, 4)
      .to.emit(minter, "SlotChanged")
      .withArgs(4, 0, 1)
      .to.emit(minter, "Transfer")
      .withArgs(ethers.constants.AddressZero, user.address, 5)
      .to.emit(minter, "SlotChanged")
      .withArgs(5, 0, 1);

    expect(await minter.ownerOf(1)).to.be.eq(user.address);
    expect(await minter.slotOf(1)).to.be.eq(1);
    expect(await minter.slotOf(2)).to.be.eq(1);
    expect(await minter.slotOf(3)).to.be.eq(1);
    expect(await minter.slotOf(4)).to.be.eq(1);
    expect(await minter.slotOf(5)).to.be.eq(1);
    expect(await minter.tokenSupplyInSlot(1)).to.be.eq(100);
    // expect(await minter.totalValueInSlot(1)).to.be.eq(100);

    expect(await minter["balanceOf(uint256)"](1)).to.be.eq("50");
    expect(await minter["balanceOf(uint256)"](2)).to.be.eq("30");
    expect(await minter["balanceOf(uint256)"](3)).to.be.eq("10");
    expect(await minter["balanceOf(uint256)"](4)).to.be.eq("5");
    expect(await minter["balanceOf(uint256)"](5)).to.be.eq("5");

    expect(await minter.tokenURI(1)).to.be.eq("ipfs://mockedImpactClaim");
  });

  it.skip("should allow fraction owner to merge a cert fraction into an existing fraction", async function () {
    const { user, minter } = await setupTest();
    const data = await getEncodedImpactClaim({ fractions: [20, 30, 50] });

    await minter.mint(user.address, data);

    expect(await minter["balanceOf(uint256)"](1)).to.be.eq("20");
    expect(await minter["balanceOf(uint256)"](2)).to.be.eq("30");
    expect(await minter["balanceOf(uint256)"](3)).to.be.eq("50");
    // expect(await minter.tokenSupplyInSlot(1)).to.be.eq(3);
    // expect(await minter.val(1)).to.be.eq(100);

    await expect(user.minter.merge([1, 2]))
      .to.emit(minter, "TransferValue")
      .withArgs(1, 2, 20);

    await expect(minter["balanceOf(uint256)"](1)).to.be.revertedWith("NonExistentToken");
    expect(await minter["balanceOf(uint256)"](2)).to.be.eq("50");
    expect(await minter["balanceOf(uint256)"](3)).to.be.eq("50");
    // expect(await minter.tokenSupplyInSlot(1)).to.be.eq(2);
    // expect(await minter.totalValueInSlot(1)).to.be.eq(100);
  });
}
