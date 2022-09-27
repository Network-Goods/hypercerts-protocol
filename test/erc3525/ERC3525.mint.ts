import { expect } from "chai";
import { ethers } from "hardhat";

import { setupTestERC3525 } from "../setup";

export function shouldBehaveLikeSemiFungibleTokenMint(): void {
  describe("ERC3525 allows for mintin on specific slots with values", () => {
    it("allows for minting a single token in a slot with a given value", async function () {
      const { sft, user } = await setupTestERC3525();

      await expect(sft.balanceOf(0)).to.be.revertedWith("ERC3525: balance query for nonexistent token");
      await expect(sft.slotOf(0)).to.be.revertedWith("ERC3525: slot query for nonexistent token");
      await expect(sft.mintValue(ethers.constants.AddressZero, 0, 0, 1_000_000)).to.be.revertedWith(
        "ERC3525: mint to the zero address",
      );
      await expect(sft.mintValue(user.address, 0, 0, 1_000_000)).to.be.revertedWith(
        "ERC3525: cannot mint zero tokenId",
      );

      await expect(sft.mintValue(user.address, 1, 0, 1_000_000))
        .to.emit(sft, "TransferValue")
        .withArgs(0, 1, 1_000_000);
      await expect(sft.mintValue(user.address, 1, 0, 1_000_000)).to.be.revertedWith("ERC3525: token already minted");

      expect(sft.slotCount(1));
      expect(sft.tokenSupplyInSlot(0)).to.be("1");
      expect(sft.tokenInSlotByIndex(0, 0).to.be("1"));
      expect(sft.balanceOf(1)).to.be("1_000_000");
    });

    it("allows for minting another token in a slot with a given value", async function () {
      const { sft, user } = await setupTestERC3525();

      await expect(sft.mintValue(user.address, 1, 0, 1_000_000))
        .to.emit(sft, "TransferValue")
        .withArgs(0, 1, 1_000_000);

      expect(sft.balanceOf(1)).to.be("1_000_000");
      await expect(sft.balanceOf(2)).to.be.revertedWith("ERC3525: slot query for nonexistent token");

      await expect(sft.mintValue(user.address, 2, 0, 2_000_000))
        .to.emit(sft, "TransferValue")
        .withArgs(0, 2, 2_000_000);

      expect(sft.tokenSupplyInSlot(0)).to.be("2");
      expect(sft.tokenInSlotByIndex(0, 0).to.be("1"));
      expect(sft.tokenInSlotByIndex(0, 1).to.be("2"));

      expect(sft.balanceOf(1)).to.be("1_000_000");
      expect(sft.balanceOf(2)).to.be("2_000_000");
    });
  });
}
