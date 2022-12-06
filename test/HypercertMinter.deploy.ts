import { expect } from "chai";
import { ethers } from "hardhat";

describe("Hypercert Minter", function () {
  it("is an initializable ERC3525 contract", async () => {
    const tokenFactory = await ethers.getContractFactory("HypercertMinter");
    const tokenInstance = await tokenFactory.deploy();

    await expect(tokenInstance.initialize()).to.be.revertedWith("Initializable: contract is already initialized");
  });
});
