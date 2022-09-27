import { setupTestERC3525 } from "../setup";

export function shouldBehaveLikeSemiFungibleTokenTransfer(): void {
  describe("ERC3525 supports transfers on slot and token level", function () {
    it.skip("allows for minting NFTs with identical slots", async function () {
      const { sft } = await setupTestERC3525();
    });
  });
}
