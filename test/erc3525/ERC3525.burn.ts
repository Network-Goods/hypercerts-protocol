import { expect } from "chai";

import { setupTestERC3525 } from "../setup";

export function shouldBehaveLikeSemiFungibleTokenBurn(): void {
  describe("ERC3525 allows for burning specific tokens", () => {
    it("allows for burning a specific token the callers owns", async function () {
      const { sft, user } = await setupTestERC3525();

      await sft.mintValue(user.address, 1, 1, 1_000_000);

      await expect(sft.burn(1)).to.be.revertedWith("NotApprovedOrOwner");
      await expect(user.sft.burn(1)).to.emit(sft, "SlotChanged").withArgs(1, 1, 0);
    });

    it("does not allow burning other tokens in the same slot the caller does not own", async function () {
      const { sft, user, anon } = await setupTestERC3525();

      await sft.mintValue(user.address, 1, 1, 1_000_000);
      await sft.mintValue(anon.address, 2, 1, 1_000_000);

      await expect(user.sft.burn(2)).to.be.revertedWith("NotApprovedOrOwner");
    });
  });
}
