import { expect } from "chai";
import { ContractTransaction } from "ethers";
import { ethers } from "hardhat";

import { ERC3525_Testing } from "../../src/types";
import { setupTestERC3525 } from "../setup";

type AddressedERC3525 = {
  sft: ERC3525_Testing;
  address: string;
};

export const shouldBehaveLikeSemiFungibleTokenApprovals = () => {
  describe("ERC3525 allows for approvals", () => {
    const tokenId1 = 1;
    const tokenId2 = 2;
    const tokenId3 = 200;
    const slot = 1;

    it("reverts isApprovedOrOwner check on non-existent token", async () => {
      const { sft, user } = await setupTestERC3525();
      await expect(sft.isApprovedOrOwner(user.address, 1)).to.be.revertedWith("NonExistentToken");
    });

    const testCases = <
      [string, (user: AddressedERC3525, anon: AddressedERC3525) => Promise<ContractTransaction>, string, string][]
    >[
      ["burn", (_user, anon) => anon.sft.burn(tokenId1), "NotApprovedOrOwner", "Transfer"],
      [
        "transfer value",
        (_user, anon) => anon.sft["transferFrom(uint256,uint256,uint256)"](tokenId1, tokenId2, 500_000),
        "InsufficientAllowance(500000, 0)",
        "TransferValue",
      ],
      [
        "transfer token",
        (user, anon) => anon.sft["transferFrom(address,address,uint256)"](user.address, anon.address, tokenId1),
        "NotApprovedOrOwner",
        "Transfer",
      ],
    ];

    testCases.forEach(([name, fn, revertMessage, successEvent]) => {
      it(`allows approval for specific token - ${name}`, async () => {
        const { sft, user, anon } = await setupTestERC3525();

        await sft.mintValue(user.address, slot, 1_000_000);
        await sft.mintValue(anon.address, slot, 1_000_000);

        expect(await sft.getApproved(tokenId1)).to.be.eq(ethers.constants.AddressZero);

        // Custom errors
        await expect(sft.getApproved(tokenId3)).to.be.revertedWith("NonExistentToken");
        await expect(user.sft["approve(address,uint256)"](user.address, tokenId1)).to.be.revertedWith(
          "InvalidApproval",
        );
        await expect(user.sft["approve(address,uint256)"](user.address, tokenId3)).to.be.revertedWith(
          "NonExistentToken",
        );
        await expect(anon.sft["approve(address,uint256)"](anon.address, tokenId1)).to.be.revertedWith(
          "NotApprovedOrOwner",
        );

        await expect(fn(user, anon)).to.be.revertedWith(revertMessage);

        await expect(user.sft["approve(address,uint256)"](anon.address, tokenId1))
          .to.emit(sft, "Approval")
          .withArgs(user.address, anon.address, tokenId1);

        expect(await sft.getApproved(tokenId1)).to.be.eq(anon.address);

        await expect(fn(user, anon)).to.emit(sft, successEvent);
      });

      testCases.forEach(([name, fn, revertMessage, successEvent]) => {
        it(`allows approval for all - ${name}`, async () => {
          const { sft, user, anon } = await setupTestERC3525();

          await user.sft.mintValue(user.address, slot, 1_000_000);
          await user.sft.mintValue(user.address, slot, 1_000_000);
          expect(await sft.isApprovedForAll(user.address, anon.address)).to.be.false;

          // Custom errors
          await expect(user.sft.setApprovalForAll(user.address, true)).to.be.revertedWith("InvalidApproval");

          await expect(fn(user, anon)).to.be.revertedWith(revertMessage);

          await expect(user.sft.setApprovalForAll(anon.address, true))
            .to.emit(sft, "ApprovalForAll")
            .withArgs(user.address, anon.address, true);

          expect(await sft.isApprovedForAll(user.address, anon.address)).to.be.true;

          await expect(fn(user, anon)).to.emit(sft, successEvent);
        });
      });
    });
  });
};
