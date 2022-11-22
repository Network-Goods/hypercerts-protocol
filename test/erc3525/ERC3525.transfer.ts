import { expect } from "chai";

import { setupTestERC3525 } from "../setup";

export function shouldBehaveLikeSemiFungibleTokenTransfer(): void {
  describe("ERC3525 supports transfers on slot and token level", function () {
    it("allows for transfering tokens between addresses", async function () {
      const { sft, user, anon } = await setupTestERC3525();
      await sft.mintValue(user.address, 1, 1_000_000);

      expect(await sft.ownerOf(1)).to.be.eq(user.address);
      expect(await sft["balanceOf(uint256)"](1)).to.be.eq("1000000");

      await expect(user.sft["transferFrom(address,address,uint256)"](user.address, anon.address, 1))
        .to.emit(sft, "Transfer")
        .withArgs(user.address, anon.address, 1);

      expect(await sft.ownerOf(1)).to.be.eq(anon.address);
    });

    it("allows for transfering values between tokens with identical slots", async function () {
      const { sft, user } = await setupTestERC3525();

      await expect(sft.transferValue(1, 2, 1_234_5678)).to.be.revertedWith("NonExistentToken(1)");

      await sft.mintValue(user.address, 0, 1_000_000);

      await expect(sft.transferValue(1, 2, 500_000)).to.be.revertedWith("NonExistentToken(2)");

      await sft.mintValue(user.address, 0, 2_000_000);

      await expect(sft.transferValue(1, 2, 8_796_543)).to.be.revertedWith("InsufficientBalance(8796543, 1000000)");

      await expect(sft.transferValue(1, 2, 500_000)).to.emit(sft, "TransferValue").withArgs(1, 2, 500_000);

      expect(await sft["balanceOf(uint256)"](1)).to.be.eq("500000");
      expect(await sft["balanceOf(uint256)"](2)).to.be.eq("2500000");
    });

    it("does not allow for transfering values between tokens with different slots", async function () {
      const { sft, user } = await setupTestERC3525();
      await sft.mintValue(user.address, 1, 1_000_000);
      await sft.mintValue(user.address, 2, 2_000_000);

      await expect(sft.transferValue(1, 2, 500_000)).to.be.revertedWith("SlotsMismatch(1, 2)");

      expect(await sft["balanceOf(uint256)"](1)).to.be.eq("1000000");
      expect(await sft["balanceOf(uint256)"](2)).to.be.eq("2000000");
    });

    it("allows for transfering value from a token to an address", async function () {
      const { sft, user, anon } = await setupTestERC3525();
      await sft.mintValue(user.address, 1, 1_000_000);

      expect(await sft.ownerOf(1)).to.be.eq(user.address);
      await expect(sft.ownerOf(2)).to.be.revertedWith("NonExistentToken");
      expect(await sft["balanceOf(uint256)"](1)).to.be.eq("1000000");
      await expect(sft["balanceOf(uint256)"](2)).to.be.revertedWith(`NonExistentToken`);

      await expect(user.sft["transferFrom(uint256,address,uint256)"](1, anon.address, 500_000))
        .to.emit(sft, "TransferValue")
        .withArgs(1, 2, "500000");

      expect(await sft.ownerOf(1)).to.be.eq(user.address);
      expect(await sft.ownerOf(2)).to.be.eq(anon.address);
      expect(await sft["balanceOf(uint256)"](1)).to.be.eq("500000");
      expect(await sft["balanceOf(uint256)"](2)).to.be.eq("500000");
    });

    it("doesnt decrease total supply after nfts have been merged", async function () {
      const { sft, user } = await setupTestERC3525();
      await sft.mintValue(user.address, 1, 10);
      await user.sft.splitValue(1, 5);
      expect(await sft["balanceOf(address)"](user.address)).to.be.equal(2);
      await user.sft.mergeValue(2, 1);
      await user.sft.burn(2);
      expect(await sft["balanceOf(address)"](user.address)).to.be.equal(1);

      //fails: totalSupply is still 2
      expect(await sft.totalSupply()).to.be.equal(1);
    });
  });
}
