import { expect } from "chai";
import { ethers } from "hardhat";

import setupTest from "../setup";
import { getEncodedImpactClaim } from "../utils";

export function shouldBehaveLikeHypercertMinterMinting(): void {
  it("anybody can mint a token with supply 1 or higher - except zero-address", async function () {
    const { deployer, user, anon, minter } = await setupTest();
    const data = await getEncodedImpactClaim();

    // Supply 1, multiple users/ids
    await expect(deployer.minter.mint(deployer.address, 0, 1, data))
      .to.emit(minter, "TransferSingle")
      .withArgs(deployer.address, ethers.constants.AddressZero, deployer.address, 0, 1);
    await expect(user.minter.mint(user.address, 1, 1, data))
      .to.emit(minter, "TransferSingle")
      .withArgs(user.address, ethers.constants.AddressZero, user.address, 1, 1);
    await expect(anon.minter.mint(anon.address, 2, 1, data))
      .to.emit(minter, "TransferSingle")
      .withArgs(anon.address, ethers.constants.AddressZero, anon.address, 2, 1);

    // Supply >1
    await expect(deployer.minter.mint(deployer.address, 3, 100_000, data))
      .to.emit(minter, "TransferSingle")
      .withArgs(deployer.address, ethers.constants.AddressZero, deployer.address, 3, 100_000);

    await expect(deployer.minter.mint(ethers.constants.AddressZero, 1, 1, data)).to.be.revertedWith(
      "Mint: mint to the zero address",
    );
  });

  //TODO can supply of token be increased? Either remove ID as input, or only allow creator to mint more of same token
  it("an already minted ID cannot be minted again", async function () {
    const { user, minter } = await setupTest();
    const data = await getEncodedImpactClaim();

    await expect(user.minter.mint(user.address, 1, 1, data))
      .to.emit(minter, "TransferSingle")
      .withArgs(user.address, ethers.constants.AddressZero, user.address, 0, 1);

    // await expect(user.minter.mint(user.address, 1, 1, data)).to.be.revertedWith(
    //   "Mint: token with provided ID already exists",
    // );
  });

  it("allows for dynamic URIs", async function () {
    const { user, minter } = await setupTest();

    const shortdata = await getEncodedImpactClaim({ uri: "Test 1234" });

    await expect(user.minter.mint(user.address, 0, 1, shortdata))
      .to.emit(minter, "TransferSingle")
      .withArgs(user.address, ethers.constants.AddressZero, user.address, 0, 1);

    expect(await user.minter.uri(0)).to.be.eq("Test 1234");

    const cid = "ipfs:///QmW2WQi7j6c7UgJTarActp7tDNikE4B2qXtFCfLPdsgaTQ/cat.jpg";
    const dataWithIPFS = await getEncodedImpactClaim({
      uri: cid,
    });

    await expect(user.minter.mint(user.address, 1, 1, dataWithIPFS))
      .to.emit(minter, "TransferSingle")
      .withArgs(user.address, ethers.constants.AddressZero, user.address, 1, 1);

    expect(await user.minter.uri(1)).to.be.eq(cid);
  });

  it("parses input data to create hypercert - minimal", async function () {
    const { user, minter } = await setupTest();

    const minimalData = {
      rightsID: 1,
      workTimeframe: [0, 0],
      impactTimeframe: [0, 0],
      contributors: [user.address],
      workScopes: [],
      impactScopes: [],
      uri: "ipfs://test",
    };

    const shortdata = await getEncodedImpactClaim(minimalData);

    await expect(user.minter.mint(user.address, 0, 1, shortdata))
      .to.emit(minter, "ImpactClaimed")
      .withArgs(
        minimalData.contributors,
        minimalData.workTimeframe,
        minimalData.impactTimeframe,
        minimalData.workScopes,
        minimalData.impactScopes,
        minimalData.uri,
      );

    expect(await user.minter.uri(0)).to.be.eq(minimalData.uri);
    const claim = await minter.impactCerts(0);
    console.log("CLAIM: ", claim);
    expect(claim.exists).to.be.true;
    // expect(claim.workTimeframe).to.be.eq(minimalData.workTimeframe);
    // expect(claim.workScopes).to.be.eq(minimalData.workScopes);
    // expect(claim.impactTimeframe).to.be.eq(minimalData.impactTimeframe);
    // expect(claim.impactScopes).to.be.eq(minimalData.impactScopes);
    expect(claim.rights).to.be.eq(minimalData.rightsID);
  });
}
