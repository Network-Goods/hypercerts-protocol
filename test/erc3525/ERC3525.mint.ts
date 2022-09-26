import { ethers } from "hardhat";

import { setupTestERC3525 } from "../setup";
import { ERC3525 } from "../wellKnown";

export function shouldBehaveLikeSemiFungibleTokenMint(): void {
  describe("ERC3525 supports minting token with a slot-dimension"),
    () => {
      beforeEach(async () => {
        const tokenFactory = await ethers.getContractFactory(ERC3525);
        const tokenInstance = await tokenFactory.deploy();

        tokenInstance.initialize();
      });

      it("allows for minting a single token", async function () {
        expect(await minter.workScopes(Object.keys(WorkScopes)[0])).to.be.eq("clean-air-tech");
      });
    };
}
