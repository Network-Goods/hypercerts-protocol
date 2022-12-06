import { expect } from "chai";
import { ethers, getNamedAccounts } from "hardhat";

import { ERC3525_Testing } from "../../src/types";
import { ERC3525 } from "../wellKnown";
import { shouldBehaveLikeSemiFungibleTokenAllowances } from "./ERC3525.allowances";
import { shouldBehaveLikeSemiFungibleTokenApprovals } from "./ERC3525.approvals";
import { shouldBehaveLikeSemiFungibleTokenBurn } from "./ERC3525.burn";
import { shouldBehaveLikeSemiFungibleTokenMint } from "./ERC3525.mint";
import { shouldBehaveLikeSemiFungibleTokenMiscellaneous } from "./ERC3525.miscellaneous";
import { shouldBehaveLikeSemiFungibleTokenTransfer } from "./ERC3525.transfer";

describe("Unit tests", function () {
  describe("ERC3525", function () {
    it("is an initializable ERC3525 contract", async () => {
      const tokenFactory = await ethers.getContractFactory(ERC3525);
      const tokenInstance = await tokenFactory.deploy();

      // 0x01ffc9a7 is the ERC165 interface identifier for EIP165 - interfaces
      expect(await tokenInstance.supportsInterface("0x01ffc9a7")).to.be.true;

      // 0xd9b67a26 is the ERC165 interface identifier for EIP3525 - SFT
      expect(await tokenInstance.supportsInterface("0xd5358140")).to.be.true;

      // 0x80ac58cd is the ERC165 interface identifier for EIP721 - backward compatible with NFT
      expect(await tokenInstance.supportsInterface("0x80ac58cd")).to.be.true;

      await expect(tokenInstance.initialize()).to.be.revertedWith("Initializable: contract is already initialized");
    });

    it("supports enumerable slots", async () => {
      const tokenFactory = await ethers.getContractFactory(ERC3525);
      const tokenInstance = await tokenFactory.deploy();

      // 0x3b741b9e is the ERC165 interface identifier for IERC3525SlotEnumerable
      expect(await tokenInstance.supportsInterface("0x3b741b9e")).to.be.true;

      expect(await tokenInstance.slotCount()).to.eq(0);
      await expect(tokenInstance.slotByIndex(0)).to.be.reverted;
      expect(await tokenInstance.tokenSupplyInSlot(0)).to.eq(0);
      await expect(tokenInstance.tokenInSlotByIndex(0, 0)).to.be.reverted;
    });

    it("supports ERC3525 metadata", async () => {
      const tokenFactory = await ethers.getContractFactory(ERC3525);
      const tokenInstance = <ERC3525_Testing>await tokenFactory.deploy();
      const { deployer } = await getNamedAccounts();

      // 0xe1600902 is the ERC165 interface identifier for IERC3525Metadata
      expect(await tokenInstance.supportsInterface("0xe1600902")).to.be.true;

      expect(await tokenInstance.contractURI().then((res: string) => res.startsWith(`data:application/json;`))).to.be
        .true;
      expect(await tokenInstance.slotURI(0).then((res: string) => res.startsWith(`data:application/json;`))).to.be.true;

      await tokenInstance.mintValue(deployer, 12345, 10000);
      expect(await tokenInstance.tokenURI(1).then((res: string) => res.startsWith(`data:application/json;`))).to.be
        .true;
    });

    shouldBehaveLikeSemiFungibleTokenMint();
    shouldBehaveLikeSemiFungibleTokenTransfer();
    shouldBehaveLikeSemiFungibleTokenBurn();
    shouldBehaveLikeSemiFungibleTokenAllowances();
    shouldBehaveLikeSemiFungibleTokenApprovals();
    shouldBehaveLikeSemiFungibleTokenMiscellaneous();
  });
});
