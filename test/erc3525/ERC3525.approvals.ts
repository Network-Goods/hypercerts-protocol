import { expect } from "chai";
import { ethers } from "hardhat";

import { setupTestERC3525 } from "../setup";

export function shouldBehaveLikeSemiFungibleTokenApprovals(): void {
  describe("ERC3525 allows for approvals", () => {
    it("allows approval for spedific token", async function () {
      const { sft, user, anon } = await setupTestERC3525();

      const tokenId = 1;
      await user.sft.mintValue(user.address, 1, 1_000_000);
      expect(await sft.getApproved(tokenId)).to.be.eq(ethers.constants.AddressZero);

      await expect(sft.getApproved(tokenId + 1)).to.be.revertedWith("NonExistentToken");

      // Custom errors
      await expect(user.sft["approve(address,uint256)"](user.address, tokenId)).to.be.revertedWith("InvalidApproval");

      await expect(
        anon.sft["transferFrom(address,address,uint256)"](user.address, anon.address, tokenId),
      ).to.be.revertedWith("NotApprovedOrOwner");

      await expect(user.sft["approve(address,uint256)"](anon.address, tokenId))
        .to.emit(sft, "Approval")
        .withArgs(user.address, anon.address, tokenId);

      expect(await sft.getApproved(tokenId)).to.be.eq(anon.address);

      await expect(anon.sft["transferFrom(address,address,uint256)"](user.address, anon.address, tokenId))
        .to.emit(sft, "Transfer")
        .withArgs(user.address, anon.address, tokenId);
    });

    it("allows approval for all", async function () {
      const { sft, user, anon } = await setupTestERC3525();

      await user.sft.mintValue(user.address, 1, 1_000_000);
      expect(await sft.isApprovedForAll(user.address, anon.address)).to.be.false;

      // Custom errors
      await expect(user.sft.setApprovalForAll(user.address, true)).to.be.revertedWith("InvalidApproval");

      await expect(anon.sft.burn(1)).to.be.revertedWith("NotApprovedOrOwner");

      await expect(user.sft.setApprovalForAll(anon.address, true))
        .to.emit(sft, "ApprovalForAll")
        .withArgs(user.address, anon.address, true);

      expect(await sft.isApprovedForAll(user.address, anon.address)).to.be.true;

      await expect(anon.sft.burn(1)).to.emit(sft, "Transfer").withArgs(1, user.address, ethers.constants.AddressZero);
    });
  });
}
