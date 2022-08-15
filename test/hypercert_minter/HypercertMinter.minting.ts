import { expect } from "chai";
import { ethers } from "hardhat";

import setupTest from "../setup";

export function shouldBehaveLikeHypercertMinterMinting(): void {
  it("anybody can mint a token with supply 1 or higher", async function () {
    const { deployer, user, anon, minter } = await setupTest();

    // Supply 1, multiple users/ids
    await expect(deployer.minter.mint(deployer.address, 1, 1, "0x"))
      .to.emit(minter, "TransferSingle")
      .withArgs(deployer.address, ethers.constants.AddressZero, deployer.address, 1, 1);
    await expect(user.minter.mint(user.address, 2, 1, "0x"))
      .to.emit(minter, "TransferSingle")
      .withArgs(user.address, ethers.constants.AddressZero, user.address, 2, 1);
    await expect(anon.minter.mint(anon.address, 3, 1, "0x"))
      .to.emit(minter, "TransferSingle")
      .withArgs(anon.address, ethers.constants.AddressZero, anon.address, 3, 1);

    // Supply >1
    await expect(deployer.minter.mint(deployer.address, 4, 100_000, "0x"))
      .to.emit(minter, "TransferSingle")
      .withArgs(deployer.address, ethers.constants.AddressZero, deployer.address, 4, 100_000);
  });

  it("an already minted ID cannot be minted again", async function () {
    const { user, minter } = await setupTest();

    await expect(user.minter.mint(user.address, 1, 1, "0x"))
      .to.emit(minter, "TransferSingle")
      .withArgs(user.address, ethers.constants.AddressZero, user.address, 1, 1);

    await expect(user.minter.mint(user.address, 1, 1, "0x")).to.be.revertedWith(
      "Mint: token with provided ID already exists",
    );
  });

  it("allows for dynamic URIs", async function () {
    const { user, minter } = await setupTest();

    await expect(user.minter.mint(user.address, 1, 1, ethers.utils.toUtf8Bytes("Test 1234")))
      .to.emit(minter, "TransferSingle")
      .withArgs(user.address, ethers.constants.AddressZero, user.address, 1, 1);

    expect(await user.minter.uri(1)).to.be.eq("Test 1234");

    await expect(
      user.minter.mint(
        user.address,
        2,
        1,
        ethers.utils.toUtf8Bytes("https://ipfs.io/ipfs/QmW2WQi7j6c7UgJTarActp7tDNikE4B2qXtFCfLPdsgaTQ/cat.jpg"),
      ),
    )
      .to.emit(minter, "TransferSingle")
      .withArgs(user.address, ethers.constants.AddressZero, user.address, 2, 1);

    expect(await user.minter.uri(2)).to.be.eq(
      "https://ipfs.io/ipfs/QmW2WQi7j6c7UgJTarActp7tDNikE4B2qXtFCfLPdsgaTQ/cat.jpg",
    );
  });
}
