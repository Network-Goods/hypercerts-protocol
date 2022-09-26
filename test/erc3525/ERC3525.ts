import { expect } from "chai";
import { ethers } from "hardhat";

import { ERC3525 } from "../wellKnown";
import { shouldBehaveLikeSemiFungibleTokenMint } from "./ERC3525.mint";
import { shouldBehaveLikeSemiFungibleTokenTransfer } from "./ERC3525.transfer";

describe("Unit tests", function () {
  describe("ERC2525", function () {
    it("is an initializable ERC3525 contract", async () => {
      const tokenFactory = await ethers.getContractFactory(ERC3525);
      const tokenInstance = await tokenFactory.deploy();

      // 0x01ffc9a7 is the ERC165 interface identifier for EIP165
      expect(await tokenInstance.supportsInterface("0x01ffc9a7")).to.be.true;

      // 0xd9b67a26 is the ERC165 interface identifier for EIP3525
      expect(await tokenInstance.supportsInterface("0xd5358140")).to.be.true;

      // 0x80ac58cd is the ERC165 interface identifier for EIP721
      expect(await tokenInstance.supportsInterface("0x80ac58cd")).to.be.true;

      await expect(tokenInstance.initialize()).to.emit(tokenInstance, "Initialized").withArgs(1);
      await expect(tokenInstance.initialize()).to.be.revertedWith("Initializable: contract is already initialized");
    });

    it("supports enumerable slots", async () => {
      const tokenFactory = await ethers.getContractFactory(ERC3525);
      const tokenInstance = await tokenFactory.deploy();

      // 0x3b741b9e is the ERC165 interface identifier for IERC3525SlotEnumerable
      expect(await tokenInstance.supportsInterface("0x3b741b9e")).to.be.true;

      expect(await tokenInstance.slotCount()).to.be("0");
      await expect(tokenInstance.slotByIndex(0)).to.be.reverted;
      expect(await tokenInstance.tokenSupply(0)).to.be("0");
      await expect(tokenInstance.tokenInSlotByIndex(0)(0)).to.be.reverted;
    });

    it("supports ERC3525 metadata", async () => {
      const tokenFactory = await ethers.getContractFactory(ERC3525);
      const tokenInstance = await tokenFactory.deploy();

      // 0xe1600902 is the ERC165 interface identifier for IERC3525Metadata
      expect(await tokenInstance.supportsInterface("0xe1600902")).to.be.true;

      expect(await tokenInstance.contractURI().then((res: string) => res.includes(`data:application/json;`))).to.be
        .true;
      expect(await tokenInstance.slotURI().then((res: string) => res.includes(`data:application/json;`))).to.be.true;
    });

    shouldBehaveLikeSemiFungibleTokenMint();
    shouldBehaveLikeSemiFungibleTokenTransfer();
  });
});
