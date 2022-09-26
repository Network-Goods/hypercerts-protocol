import { expect } from "chai";
import { ethers } from "hardhat";

import { ERC3525 } from "../wellKnown";

describe("Unit tests", function () {
  describe("ERC2525", function () {
    it("is an initializable ERC3525 contract", async () => {
      const tokenFactory = await ethers.getContractFactory(ERC3525);
      const tokenInstance = await tokenFactory.deploy();

      // 0xd9b67a26 is the ERC165 interface identifier for EIP3525
      expect(await tokenInstance.supportsInterface("0xd5358140")).to.be.true;

      await expect(tokenInstance.initialize()).to.not.be.reverted;
      await expect(tokenInstance.initialize()).to.be.revertedWith("Initializable: contract is already initialized");
    });
  });
});
