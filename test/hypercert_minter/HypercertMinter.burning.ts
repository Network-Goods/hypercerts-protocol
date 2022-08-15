import { expect } from "chai";
import { ethers } from "hardhat";

import setupTest from "../setup";

export function shouldBehaveLikeHypercertMinterBurning(): void {
  it("owner can burn a token", async function () {
    const { deployer, minter } = await setupTest();

    // Supply 1, single user/id
    await expect(deployer.minter.mint(deployer.address, 1, 1, "0x"))
      .to.emit(minter, "TransferSingle")
      .withArgs(deployer.address, ethers.constants.AddressZero, deployer.address, 1, 1);
    await expect(deployer.minter.burn(deployer.address, 1, 1))
      .to.emit(minter, "TransferSingle")
      .withArgs(deployer.address, deployer.address, ethers.constants.AddressZero, 1, 1);
    expect(await deployer.minter.balanceOf(deployer.address, 1)).to.equal(0);
  });

  it("user cannot burn another's token", async function () {
    const { deployer, user, minter } = await setupTest();

    // Supply 1, multiple users/ids
    await expect(deployer.minter.mint(deployer.address, 1, 1, "0x"))
      .to.emit(minter, "TransferSingle")
      .withArgs(deployer.address, ethers.constants.AddressZero, deployer.address, 1, 1);
    await expect(user.minter.burn(deployer.address, 1, 1)).to.be.revertedWith(
      "ERC1155: caller is not token owner nor approved",
    );
  });
}
