import { expect } from "chai";
import { ethers, getNamedAccounts } from "hardhat";

import { HyperCertMinter as Minter } from "../../src/types";
import { HyperCertMinter } from "../wellKnown";
import { shouldBehaveLikeHypercertMinterBurning as shouldBehaveLikeHyperCertMinterBurning } from "./HyperCertMinter.burning";
import { shouldBehaveLikeHypercertMinterIntegration } from "./HyperCertMinter.integration";
import { shouldBehaveLikeHypercertMinterMinting as shouldBehaveLikeHyperCertMinterMinting } from "./HyperCertMinter.minting";
import { shouldBehaveLikeHypercertMinterAddingRights as shouldBehaveLikeHyperCertMinterAddingRights } from "./HyperCertMinter.rights";
import {
  shouldBehaveLikeHyperCertMinterAddingImpactScopes,
  shouldBehaveLikeHyperCertMinterAddingWorkScopes,
} from "./HyperCertMinter.scopes";
import { shouldBehaveLikeHypercertMinterSplitAndMerge as shouldBehaveLikeHyperCertMinterSplitAndMerge } from "./HyperCertMinter.split.merge";
import { shouldBehaveLikeHypercertMinterUpgrade as shouldBehaveLikeHyperCertMinterUpgrade } from "./HyperCertMinter.upgrade";

describe("Unit tests", function () {
  describe("HyperCert Minter", function () {
    it("is an initializable ERC3525 contract", async () => {
      const tokenFactory = await ethers.getContractFactory(HyperCertMinter);
      const tokenInstance = <Minter>await tokenFactory.deploy();
      const { anon } = await getNamedAccounts();

      // 0xd5358140 is the ERC165 interface identifier for EIP3525
      expect(await tokenInstance.supportsInterface("0xd5358140")).to.be.true;
      expect(await tokenInstance.name()).to.be.eq("HyperCerts");
      expect(await tokenInstance.symbol()).to.be.eq("HCRT");
      expect(await tokenInstance.valueDecimals()).to.be.eq(0);

      await expect(tokenInstance.initialize(anon)).to.be.revertedWith("Initializable: contract is already initialized");
    });

    shouldBehaveLikeHyperCertMinterMinting();
    shouldBehaveLikeHyperCertMinterUpgrade();
    shouldBehaveLikeHyperCertMinterBurning();
    shouldBehaveLikeHyperCertMinterAddingImpactScopes();
    shouldBehaveLikeHyperCertMinterAddingWorkScopes();
    shouldBehaveLikeHyperCertMinterAddingRights();
    shouldBehaveLikeHyperCertMinterSplitAndMerge();
    shouldBehaveLikeHypercertMinterIntegration();
  });
});
