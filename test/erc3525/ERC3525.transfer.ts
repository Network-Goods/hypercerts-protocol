import { expect } from "chai";

import { setupTestERC3525 } from "../setup";

export function shouldBehaveLikeSemiFungibleTokenTransfer(): void {
  describe("ERC3525 supports transfers on slot and token level", function () {
    it("allows for transfering values between tokens with identical slots", async function () {
      const { sft, user } = await setupTestERC3525();

      await expect(sft.transferValue(user.address, 1, 2, 1_234_5678)).to.be.revertedWith(
        "ERC35255: transfer from nonexistent token",
      );

      await sft.mintValue(user.address, 1, 0, 1_000_000);

      await expect(sft.transferValue(user.address, 1, 2, 500_000)).to.be.revertedWith(
        "ERC35255: transfer to nonexistent token",
      );

      await sft.mintValue(user.address, 2, 0, 2_000_000);

      await expect(sft.transferValue(user.address, 1, 2, 8_796_543)).to.be.revertedWith(
        "ERC3525: transfer amount exceeds balance",
      );

      await expect(sft.transferValue(user.address, 1, 2, 500_000))
        .to.emit(sft, "TransferValue")
        .withArgs(1, 2, 500_000);

      expect(sft.balanceOf(1)).to.be("500_000");
      expect(sft.balanceOf(2)).to.be("2_500_000");
    });

    it("does not allow for transfering values between tokens with different slots", async function () {
      const { sft, user } = await setupTestERC3525();
      await sft.mintValue(user.address, 1, 0, 1_000_000);
      await sft.mintValue(user.address, 2, 1, 2_000_000);

      await expect(sft.transferValue(user.address, 1, 2, 500_000)).to.be.revertedWith(
        "ERC3535: transfer to token with different slot",
      );

      expect(sft.balanceOf(1)).to.be("1_000_000");
      expect(sft.balanceOf(2)).to.be("2_000_000");
    });
  });
}
