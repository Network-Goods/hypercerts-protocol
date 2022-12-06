import { expect } from "chai";
import { ethers } from "hardhat";

import { setupTestERC3525 } from "../setup";

export const shouldBehaveLikeSemiFungibleTokenMiscellaneous = () => {
  describe("ERC3525 miscellaneous", () => {
    it("reverts balance check on the zero address", async () => {
      const { sft } = await setupTestERC3525();

      await expect(sft["balanceOf(address)"](ethers.constants.AddressZero)).to.be.revertedWith("ToZeroAddress");
    });

    it("reverts out-of-range tokenByIndex request", async () => {
      const { sft } = await setupTestERC3525();

      await expect(sft.tokenByIndex(0)).to.be.revertedWith("InvalidID");
    });

    it("reverts out-of-range tokenOfOwnerByIndex request", async () => {
      const { sft, user } = await setupTestERC3525();

      await expect(sft.tokenOfOwnerByIndex(user.address, 0)).to.be.revertedWith("InvalidID");
    });
  });
};
