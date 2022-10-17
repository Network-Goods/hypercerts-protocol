import { expect } from "chai";

import { setupTestERC3525 } from "../setup";

export function shouldBehaveLikeSemiFungibleTokenBurn(): void {
  describe("ERC3525 allows for burning specific tokens", () => {
    it("allows for burning a specific token the callers owns", async function () {
      const { sft, user } = await setupTestERC3525();

      await sft.mintValue(user.address, 1, 1_000_000);

      const tokenId = 1;
      await expect(sft.burn(tokenId)).to.be.revertedWith("NotApprovedOrOwner");
      //TODO check token allocation enumeration
      await expect(user.sft.burn(tokenId)).to.emit(sft, "SlotChanged").withArgs(1, 1, 0);

      await expect(sft.ownerOf(tokenId)).to.be.revertedWith("NonExistentToken");
    });

    it("does not allow burning other tokens in the same slot the caller does not own", async function () {
      const { sft, user, anon } = await setupTestERC3525();

      await sft.mintValue(user.address, 1, 1_000_000);
      await sft.mintValue(anon.address, 1, 1_000_000);

      await expect(user.sft.burn(2)).to.be.revertedWith("NotApprovedOrOwner");
    });
  });
}
