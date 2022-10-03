import { expect } from "chai";
import { ethers } from "hardhat";

import { setupTestERC3525 } from "../setup";

export function shouldBehaveLikeSemiFungibleTokenMint(): void {
  describe("ERC3525 allows for minting on specific slots with values", () => {
    it("allows for minting a single token in a slot with a given value", async function () {
      const { sft, user } = await setupTestERC3525();

      await expect(sft["balanceOf(uint256)"](0)).to.be.revertedWith("NonExistentToken");
      await expect(sft.slotOf(0)).to.be.revertedWith("NonExistentToken");
      await expect(sft.mintValue(ethers.constants.AddressZero, 0, 0, 1_000_000)).to.be.revertedWith("ToZeroAddress");
      await expect(sft.mintValue(user.address, 0, 0, 1_000_000)).to.be.revertedWith("InvalidID(0)");

      await expect(sft.mintValue(user.address, 1, 0, 1_000_000))
        .to.emit(sft, "TransferValue")
        .withArgs(0, 1, 1_000_000);
      await expect(sft.mintValue(user.address, 1, 0, 1_000_000)).to.be.revertedWith("AlreadyMinted(1)");

      expect(await sft["tokenSupplyInSlot"](0)).to.be.eq("1");
      expect(await sft["tokenInSlotByIndex"](0, 0)).to.be.eq("1");
      expect(await sft["balanceOf(uint256)"](1)).to.be.eq("1000000");
    });

    it("allows for minting another token in a slot with a given value", async function () {
      const { sft, user } = await setupTestERC3525();

      await expect(sft.mintValue(user.address, 1, 0, 1_000_000))
        .to.emit(sft, "TransferValue")
        .withArgs(0, 1, 1_000_000);

      expect(await sft["balanceOf(uint256)"](1)).to.be.eq("1000000");
      await expect(sft["balanceOf(uint256)"](2)).to.be.revertedWith("NonExistentToken");

      await expect(sft.mintValue(user.address, 2, 0, 2_000_000))
        .to.emit(sft, "TransferValue")
        .withArgs(0, 2, 2_000_000);

      expect(await sft["tokenSupplyInSlot"](0)).to.be.eq("2");
      expect(await sft["tokenInSlotByIndex"](0, 0)).to.be.eq("1");
      expect(await sft["tokenInSlotByIndex"](0, 1)).to.be.eq("2");

      expect(await sft["balanceOf(uint256)"](1)).to.be.eq("1000000");
      expect(await sft["balanceOf(uint256)"](2)).to.be.eq("2000000");
    });
  });
}
