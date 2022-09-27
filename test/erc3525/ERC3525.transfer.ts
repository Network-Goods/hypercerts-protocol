import { expect } from "chai";

import { setupTestERC3525 } from "../setup";

export function shouldBehaveLikeSemiFungibleTokenTransfer(): void {
  describe("ERC3525 supports transfers on slot and token level", function () {
    it("allows for transfering tokens between addresses", async function () {
      const { sft, user, anon } = await setupTestERC3525();
      await sft.mintValue(user.address, 1, 0, 1_000_000);

      expect(await sft.ownerOf(1)).to.be.eq(user.address);
      expect(await sft["balanceOf(uint256)"](1)).to.be.eq("1000000");

      await expect(user.sft["transferFrom(address,address,uint256)"](user.address, anon.address, 1))
        .to.emit(sft, "Transfer")
        .withArgs(user.address, anon.address, 1);

      expect(await sft.ownerOf(1)).to.be.eq(anon.address);
    });

    it("allows for transfering values between tokens with identical slots", async function () {
      const { sft, user } = await setupTestERC3525();

      await expect(sft.transfer(1, 2, 1_234_5678)).to.be.revertedWith("ERC35255: transfer from nonexistent token");

      await sft.mintValue(user.address, 1, 0, 1_000_000);

      await expect(sft.transfer(1, 2, 500_000)).to.be.revertedWith("ERC35255: transfer to nonexistent token");

      await sft.mintValue(user.address, 2, 0, 2_000_000);

      await expect(sft.transfer(1, 2, 8_796_543)).to.be.revertedWith("ERC3525: transfer amount exceeds balance");

      await expect(sft.transfer(1, 2, 500_000)).to.emit(sft, "TransferValue").withArgs(1, 2, 500_000);

      expect(await sft["balanceOf(uint256)"](1)).to.be.eq("500000");
      expect(await sft["balanceOf(uint256)"](2)).to.be.eq("2500000");
    });

    it("does not allow for transfering values between tokens with different slots", async function () {
      const { sft, user } = await setupTestERC3525();
      await sft.mintValue(user.address, 1, 0, 1_000_000);
      await sft.mintValue(user.address, 2, 1, 2_000_000);

      await expect(sft.transfer(1, 2, 500_000)).to.be.revertedWith("ERC3535: transfer to token with different slot");

      expect(await sft["balanceOf(uint256)"](1)).to.be.eq("1000000");
      expect(await sft["balanceOf(uint256)"](2)).to.be.eq("2000000");
    });

    it("allows for transfering value from a token to an address", async function () {
      const { sft, user, anon } = await setupTestERC3525();
      await sft.mintValue(user.address, 1, 0, 1_000_000);

      expect(await sft.ownerOf(1)).to.be.eq(user.address);
      await expect(sft.ownerOf(2)).to.be.revertedWith("ERC721: invalid token ID");
      expect(await sft["balanceOf(uint256)"](1)).to.be.eq("1000000");
      await expect(sft["balanceOf(uint256)"](2)).to.be.revertedWith("ERC3525: balance query for nonexistent token");

      await expect(user.sft["transferFrom(uint256,address,uint256)"](1, anon.address, 500_000))
        .to.emit(sft, "TransferValue")
        .withArgs(1, 2, "500000");

      expect(await sft.ownerOf(1)).to.be.eq(user.address);
      expect(await sft.ownerOf(2)).to.be.eq(anon.address);
      expect(await sft["balanceOf(uint256)"](1)).to.be.eq("500000");
      expect(await sft["balanceOf(uint256)"](2)).to.be.eq("500000");
    });
  });
}
