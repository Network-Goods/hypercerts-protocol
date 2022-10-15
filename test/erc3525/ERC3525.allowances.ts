import { expect } from "chai";
import { ethers } from "hardhat";

import { setupTestERC3525 } from "../setup";

export function shouldBehaveLikeSemiFungibleTokenAllowances(): void {
  describe("ERC3525 allows for multiple levels of allowances", () => {
    it("allows for allowance on a specific token", async function () {
      const { sft, user, anon, deployer } = await setupTestERC3525();

      await deployer.sft.mintValue(user.address, 1, 1_000_000);
      expect(await sft.getApproved(1)).to.be.eq(ethers.constants.AddressZero);

      await expect(sft["approve(address,uint256)"](anon.address, 1)).to.be.revertedWith("NotApprovedOrOwner()");
      await expect(user.sft["approve(address,uint256)"](user.address, 1)).to.be.revertedWith(
        `InvalidApproval(1, "${user.address}", "${user.address}")`,
      );

      await expect(user.sft["approve(address,uint256)"](anon.address, 1))
        .to.emit(sft, "Approval")
        .withArgs(user.address, anon.address, 1);

      expect(await sft.getApproved(1)).to.be.eq(anon.address);
    });

    it("allows for allowance on a specific token's value", async function () {
      const { sft, user, anon } = await setupTestERC3525();

      await user.sft.mintValue(user.address, 1, 1_000_000);
      expect(await sft.getApproved(1)).to.be.eq(ethers.constants.AddressZero);

      // Custom errors
      await expect(sft["approve(uint256,address,uint256)"](1, anon.address, 500_000)).to.be.revertedWith(
        "NotApprovedOrOwner",
      );
      await expect(user.sft["approve(uint256,address,uint256)"](1, user.address, 500_000)).to.be.revertedWith(
        `InvalidApproval(1, "${user.address}", "${user.address}")`,
      );

      await expect(user.sft["approve(uint256,address,uint256)"](1, anon.address, 500_000))
        .to.emit(sft, "ApprovalValue")
        .withArgs(1, anon.address, "500000");

      expect(await sft.allowance(1, anon.address)).to.be.eq("500000");
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
