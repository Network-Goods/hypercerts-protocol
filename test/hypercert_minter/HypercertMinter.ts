import { expect } from "chai";
import { ethers } from "hardhat";

import { HypercertMinterV0 } from "../../src/types";
import { HypercertMetadata_V0, HypercertMinter_V0 } from "../wellKnown";
import { shouldBehaveLikeHypercertMinterBurning } from "./HypercertMinter.burning";
import { shouldBehaveLikeHypercertMinterMinting } from "./HypercertMinter.minting";
import { shouldBehaveLikeHypercertMinterAddingRights } from "./HypercertMinter.rights";
import {
  shouldBehaveLikeHypercertMinterAddingImpactScopes,
  shouldBehaveLikeHypercertMinterAddingWorkScopes,
} from "./HypercertMinter.scopes";
import { shouldBehaveLikeHypercertMinterSplitAndMerge } from "./HypercertMinter.split.merge";
import { shouldBehaveLikeHypercertMinterUpgrade } from "./HypercertMinter.upgrade";

describe("Unit tests", function () {
  describe("Hypercert Minter", function () {
    it("is an initializable ERC3525 contract", async () => {
      const HypercertMetadataFactory = await ethers.getContractFactory(HypercertMetadata_V0);
      const HypercertMetadata = await HypercertMetadataFactory.deploy();
      const tokenFactory = await ethers.getContractFactory(HypercertMinter_V0);
      const tokenInstance = <HypercertMinterV0>await tokenFactory.deploy();

      // 0xd5358140 is the ERC165 interface identifier for EIP3525
      expect(await tokenInstance.supportsInterface("0xd5358140")).to.be.true;
      expect(await tokenInstance.name()).to.be.eq("Hypercerts");
      expect(await tokenInstance.symbol()).to.be.eq("HCRT");
      expect(await tokenInstance.valueDecimals()).to.be.eq(0);

      await expect(tokenInstance.initialize(HypercertMetadata.address)).to.be.revertedWith(
        "Initializable: contract is already initialized",
      );
    });

    shouldBehaveLikeHypercertMinterMinting();
    shouldBehaveLikeHypercertMinterUpgrade();
    shouldBehaveLikeHypercertMinterBurning();
    shouldBehaveLikeHypercertMinterAddingImpactScopes();
    shouldBehaveLikeHypercertMinterAddingWorkScopes();
    shouldBehaveLikeHypercertMinterAddingRights();
    shouldBehaveLikeHypercertMinterSplitAndMerge();
  });
});
