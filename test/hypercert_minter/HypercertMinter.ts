import { expect } from "chai";
import { ethers } from "hardhat";

import { shouldBehaveLikeHypercertMinterBurning } from "./HypercertMinter.burning";
import { shouldBehaveLikeHypercertMinterMinting } from "./HypercertMinter.minting";
import { shouldBehaveLikeHypercertMinterAddingRights } from "./HypercertMinter.rights";
import {
  shouldBehaveLikeHypercertMinterAddingImpactScopes,
  shouldBehaveLikeHypercertMinterAddingWorkScopes,
} from "./HypercertMinter.scopes";
import { shouldBehaveLikeHypercertMinterUpgrade } from "./HypercertMinter.upgrade";

describe("Unit tests", function () {
  describe("Hypercert Minter", function () {
    it("is an initializable ERC1155 contract", async () => {
      const tokenFactory = await ethers.getContractFactory("HypercertMinterV0");
      const tokenInstance = await tokenFactory.deploy();

      // 0xd9b67a26 is the ERC165 interface identifier for EIP1155
      expect(await tokenInstance.supportsInterface("0xd9b67a26")).to.be.true;

      await expect(tokenInstance.initialize()).to.be.revertedWith("Initializable: contract is already initialized");
    });

    shouldBehaveLikeHypercertMinterMinting();
    shouldBehaveLikeHypercertMinterUpgrade();
    shouldBehaveLikeHypercertMinterBurning();
    shouldBehaveLikeHypercertMinterAddingImpactScopes();
    shouldBehaveLikeHypercertMinterAddingWorkScopes();
    shouldBehaveLikeHypercertMinterAddingRights();
  });
});
