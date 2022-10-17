import { expect } from "chai";
import { ethers } from "hardhat";

import { setupTestERC3525 } from "../setup";

export function shouldBehaveLikeSemiFungibleTokenAllowances(): void {
  describe("ERC3525 allows for multiple levels of allowances", () => {
    it("allows for allowance on a specific token", async function () {
      const { sft, user, anon, deployer } = await setupTestERC3525();

      await deployer.sft.mintValue(user.address, 1, 1_000_000);
      await deployer.sft.mintValue(anon.address, 1, 1_000_000);
      expect(await sft.getApproved(1)).to.be.eq(ethers.constants.AddressZero);

      await expect(anon.sft.transfer(1, 2, 100_000)).to.be.revertedWith("NotApprovedOrOwner");

      await expect(sft["approve(address,uint256)"](anon.address, 1)).to.be.revertedWith("NotApprovedOrOwner()");
      await expect(user.sft["approve(address,uint256)"](user.address, 1)).to.be.revertedWith(
        `InvalidApproval(1, "${user.address}", "${user.address}")`,
      );

      await expect(user.sft["approve(address,uint256)"](anon.address, 1))
        .to.emit(sft, "Approval")
        .withArgs(user.address, anon.address, 1);

      expect(await sft.getApproved(1)).to.be.eq(anon.address);

      await expect(anon.sft.transfer(1, 2, 100_000)).to.emit(sft, "TransferValue").withArgs(1, 2, 100_000);
    });

    it("allows for allowance on a specific token's value", async function () {
      const { sft, user, anon, deployer } = await setupTestERC3525();

      await user.sft.mintValue(user.address, 1, 1_000_000);
      await anon.sft.mintValue(anon.address, 1, 1_000_000);
      expect(await sft.getApproved(1)).to.be.eq(ethers.constants.AddressZero);

      // await expect(anon.sft.transfer(1, 2, 100_000)).to.be.revertedWith("NotApprovedOrOwner");

      // Custom errors
      await expect(deployer.sft["approve(uint256,address,uint256)"](1, anon.address, 500_000)).to.be.revertedWith(
        "NotApprovedOrOwner",
      );
      await expect(user.sft["approve(uint256,address,uint256)"](1, user.address, 500_000)).to.be.revertedWith(
        `InvalidApproval(1, "${user.address}", "${user.address}")`,
      );

      await expect(user.sft["approve(uint256,address,uint256)"](1, anon.address, 500_000))
        .to.emit(sft, "ApprovalValue")
        .withArgs(1, anon.address, 500_000);

      expect(await sft.allowance(1, anon.address)).to.be.eq(500_000);

      await expect(anon.sft.transfer(1, 2, 500_001)).to.be.revertedWith("InsufficientAllowance");
      await expect(anon.sft.transfer(1, 2, 500_000)).to.emit(sft, "TransferValue").withArgs(1, 2, 500_000);
    });
  });
}
