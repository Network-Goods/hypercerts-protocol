import { expect } from "chai";
import { ethers } from "hardhat";

import { setupTestERC3525 } from "../setup";

export function shouldBehaveLikeSemiFungibleTokenMint(): void {
  describe("ERC3525 allows for minting on specific slots with values", () => {
    it("allows for minting a single token in a slot with a given value", async function () {
      const { sft, user } = await setupTestERC3525();

      await expect(sft["balanceOf(uint256)"](0)).to.be.revertedWith("NonExistentToken");
      await expect(sft.slotOf(0)).to.be.revertedWith("NonExistentToken");
      await expect(sft.mintValue(ethers.constants.AddressZero, 0, 1_000_000)).to.be.revertedWith("ToZeroAddress");

      await expect(sft.mintValue(user.address, 1, 1_000_000)).to.emit(sft, "TransferValue").withArgs(0, 1, 1_000_000);
      await expect(sft.mintValue(user.address, 1, 1_000_000)).to.emit(sft, "TransferValue").withArgs(0, 2, 1_000_000);

      expect(await sft.totalSupply()).to.be.eq(2);
      expect(await sft.tokenByIndex(0)).to.be.eq(1);
      expect(await sft.tokenByIndex(1)).to.be.eq(2);
      expect(await sft.tokenOfOwnerByIndex(user.address, 0)).to.be.eq(1);
      expect(await sft.tokenOfOwnerByIndex(user.address, 1)).to.be.eq(2);

      expect(await sft["tokenSupplyInSlot"](1)).to.be.eq(2);
      expect(await sft["tokenInSlotByIndex"](1, 0)).to.be.eq(1);
      expect(await sft["balanceOf(uint256)"](1)).to.be.eq(1000000);
    });

    it("allows for minting another token in a slot with a given value", async function () {
      const { sft, user } = await setupTestERC3525();

      await expect(sft.mintValue(user.address, 1, 1_000_000)).to.emit(sft, "TransferValue").withArgs(0, 1, 1_000_000);

      expect(await sft["balanceOf(uint256)"](1)).to.be.eq("1000000");
      await expect(sft["balanceOf(uint256)"](2)).to.be.revertedWith("NonExistentToken");

      await expect(sft.mintValue(user.address, 1, 2_000_000)).to.emit(sft, "TransferValue").withArgs(0, 2, 2_000_000);

      expect(await sft.totalSupply()).to.be.eq(2);
      expect(await sft["tokenSupplyInSlot"](1)).to.be.eq("2");
      expect(await sft["tokenInSlotByIndex"](1, 0)).to.be.eq("1");
      expect(await sft["tokenInSlotByIndex"](1, 1)).to.be.eq("2");

      expect(await sft["balanceOf(uint256)"](1)).to.be.eq("1000000");
      expect(await sft["balanceOf(uint256)"](2)).to.be.eq("2000000");
    });

    it("enumerates slots correctly", async function () {
      const { sft, user, anon } = await setupTestERC3525();
      await sft.mintValue(user.address, 1, 10);
      await user.sft["transferFrom(uint256,address,uint256)"](1, anon.address, 5);
      expect(await sft.ownerOf(1)).to.be.eq(user.address);
      expect(await sft.ownerOf(2)).to.be.eq(anon.address);
      expect(await sft["tokenInSlotByIndex"](1, 0)).to.be.eq("1");
      expect(await sft.totalSupply()).to.be.eq(2);

      //these fail:
      //expect(await sft["tokenInSlotByIndex"](1, 1)).to.be.eq("2"); //reverts
      expect(await sft.tokenSupplyInSlot(1)).to.be.eq(2); //returns 1
    });
  });
}
