import { expect } from "chai";
import { BigNumber } from "ethers";
import { ethers } from "hardhat";

import setupTest from "../setup";
import { getEncodedImpactClaim } from "../utils";

export function shouldBehaveLikeHypercertMinterMinting(): void {
  it("anybody can mint a token with supply 1 or higher - except zero-address", async function () {
    const { deployer, user, anon, minter } = await setupTest();
    const data1 = await getEncodedImpactClaim({ workScopes: [10, 20] });
    const data2 = await getEncodedImpactClaim({ workScopes: [30, 40] });
    const data3 = await getEncodedImpactClaim({ workScopes: [20, 40] });
    const data4 = await getEncodedImpactClaim({ workScopes: [10, 40] });

    // Empty data
    await expect(deployer.minter.mint(deployer.address, 0, 1, "0x")).to.be.revertedWith("Parse: input data empty");

    // Supply 1, multiple users/ids
    await expect(deployer.minter.mint(deployer.address, 0, 1, data1))
      .to.emit(minter, "TransferSingle")
      .withArgs(deployer.address, ethers.constants.AddressZero, deployer.address, 0, 1);
    await expect(user.minter.mint(user.address, 1, 1, data2))
      .to.emit(minter, "TransferSingle")
      .withArgs(user.address, ethers.constants.AddressZero, user.address, 1, 1);
    await expect(anon.minter.mint(anon.address, 2, 1, data3))
      .to.emit(minter, "TransferSingle")
      .withArgs(anon.address, ethers.constants.AddressZero, anon.address, 2, 1);

    // Supply >1
    await expect(deployer.minter.mint(deployer.address, 3, 100_000, data4))
      .to.emit(minter, "TransferSingle")
      .withArgs(deployer.address, ethers.constants.AddressZero, deployer.address, 3, 100_000);

    await expect(deployer.minter.mint(ethers.constants.AddressZero, 1, 1, data1)).to.be.revertedWith(
      "Mint: mint to the zero address",
    );
  });

  //TODO can supply of token be increased? Either remove ID as input, or only allow creator to mint more of same token
  it("an already minted claim cannot be minted again", async function () {
    const { user, minter } = await setupTest();
    const data = await getEncodedImpactClaim();

    await expect(user.minter.mint(user.address, 1, 1, data))
      .to.emit(minter, "TransferSingle")
      .withArgs(user.address, ethers.constants.AddressZero, user.address, 0, 1);

    await expect(user.minter.mint(user.address, 1, 1, data)).to.be.revertedWith("Mint: cert with claim already exists");

    const otherData = await getEncodedImpactClaim({ workScopes: [21, 22] });

    await expect(user.minter.mint(user.address, 1, 1, otherData))
      .to.emit(minter, "TransferSingle")
      .withArgs(user.address, ethers.constants.AddressZero, user.address, 1, 1);
  });

  it("allows for dynamic URIs", async function () {
    const { user, minter } = await setupTest();

    const shortdata = await getEncodedImpactClaim({ uri: "Test 1234" });

    await expect(user.minter.mint(user.address, 0, 1, shortdata))
      .to.emit(minter, "TransferSingle")
      .withArgs(user.address, ethers.constants.AddressZero, user.address, 0, 1);

    expect(await user.minter.uri(0)).to.be.eq("Test 1234");

    const cid = "ipfs://QmW2WQi7j6c7UgJTarActp7tDNikE4B2qXtFCfLPdsgaTQ/cat.jpg";

    const dataWithIPFS = await getEncodedImpactClaim({
      workScopes: [10, 20],
      uri: cid,
    });

    await expect(user.minter.mint(user.address, 1, 1, dataWithIPFS))
      .to.emit(minter, "TransferSingle")
      .withArgs(user.address, ethers.constants.AddressZero, user.address, 1, 1);

    expect(await user.minter.uri(1)).to.be.eq(cid);
  });

  it("parses input data to create hypercert - minimal", async function () {
    const { user, minter } = await setupTest();

    const options = {
      rightsID: 1,
      workTimeframe: [1, 2],
      impactTimeframe: [2, 3],
      contributors: [user.address],
      workScopes: [],
      impactScopes: [],
      uri: "ipfs://test",
    };

    const shortdata = await getEncodedImpactClaim(options);

    // TODO generate claimHash of options and validate in test
    await expect(user.minter.mint(user.address, 0, 1, shortdata))
      .to.emit(minter, "ImpactClaimed")
      .withArgs(
        0,
        "0x49fa5407ce171891ef7529edecd0a8cc3d263942838629d90d4b05fd5324b437",
        options.contributors,
        options.workTimeframe,
        options.impactTimeframe,
        options.workScopes,
        options.impactScopes,
        "ipfs://test",
      );

    expect(await user.minter.uri(0)).to.be.eq(options.uri);

    const claim = await minter.getImpactCert("0x49fa5407ce171891ef7529edecd0a8cc3d263942838629d90d4b05fd5324b437");

    expect(claim.exists).to.be.true;
    expect(claim.version).to.be.eq(0);

    expect(claim.workTimeframe.map((timestamp: BigNumber) => timestamp.toNumber())).to.be.eql(options.workTimeframe);
    expect(claim.workScopes).to.be.eql(options.workScopes);
    expect(claim.impactTimeframe.map((timestamp: BigNumber) => timestamp.toNumber())).to.be.eql(
      options.impactTimeframe,
    );
    expect(claim.impactScopes).to.be.eql(options.impactScopes);
    expect(claim.rights).to.be.eq(options.rightsID);
  });

  it("parses input data to create hypercert - medium", async function () {
    const { user, minter } = await setupTest();

    const options = {
      rightsID: 1,
      workTimeframe: [1, 2],
      impactTimeframe: [2, 3],
      contributors: [user.address],
      workScopes: [...Array(50).keys()],
      impactScopes: [...Array(50).keys()],
      uri: "ipfs://test",
    };

    const shortdata = await getEncodedImpactClaim(options);

    // TODO generate claimHash of options and validate in test
    await expect(user.minter.mint(user.address, 0, 1, shortdata))
      .to.emit(minter, "ImpactClaimed")
      .withArgs(
        0,
        "0xf53799dfa5502031aee1367604140178b7b2f546396dda900007567361a1a60f",
        options.contributors,
        options.workTimeframe,
        options.impactTimeframe,
        options.workScopes,
        options.impactScopes,
        "ipfs://test",
      );

    expect(await user.minter.uri(0)).to.be.eq(options.uri);

    const claim = await minter.getImpactCert("0xf53799dfa5502031aee1367604140178b7b2f546396dda900007567361a1a60f");

    expect(claim.exists).to.be.true;
    expect(claim.version).to.be.eq(0);

    expect(claim.workTimeframe.map((timestamp: BigNumber) => timestamp.toNumber())).to.be.eql(options.workTimeframe);
    expect(claim.workScopes.map((scopeID: BigNumber) => scopeID.toNumber())).to.be.eql(options.workScopes);
    expect(claim.impactTimeframe.map((timestamp: BigNumber) => timestamp.toNumber())).to.be.eql(
      options.impactTimeframe,
    );
    expect(claim.impactScopes.map((impactScope: BigNumber) => impactScope.toNumber())).to.be.eql(options.impactScopes);
    expect(claim.rights).to.be.eq(options.rightsID);
  });

  it("parses input data to create hypercert - high", async function () {
    const { user, minter } = await setupTest();

    const options = {
      rightsID: 1,
      workTimeframe: [1, 2],
      impactTimeframe: [2, 3],
      contributors: [user.address],
      workScopes: [...Array(100).keys()],
      impactScopes: [...Array(100).keys()],
      uri: "ipfs://test",
    };

    const shortdata = await getEncodedImpactClaim(options);

    // TODO generate claimHash of options and validate in test
    await expect(user.minter.mint(user.address, 0, 1, shortdata))
      .to.emit(minter, "ImpactClaimed")
      .withArgs(
        0,
        "0xd043500349eb2c06a8a519bd23a7fe13fb3c5dd47456f9956d2aefd6c5cc2aae",
        options.contributors,
        options.workTimeframe,
        options.impactTimeframe,
        options.workScopes,
        options.impactScopes,
        "ipfs://test",
      );

    expect(await user.minter.uri(0)).to.be.eq(options.uri);

    const claim = await minter.getImpactCert("0xd043500349eb2c06a8a519bd23a7fe13fb3c5dd47456f9956d2aefd6c5cc2aae");

    expect(claim.exists).to.be.true;
    expect(claim.version).to.be.eq(0);

    expect(claim.workTimeframe.map((timestamp: BigNumber) => timestamp.toNumber())).to.be.eql(options.workTimeframe);
    expect(claim.workScopes.map((scopeID: BigNumber) => scopeID.toNumber())).to.be.eql(options.workScopes);
    expect(claim.impactTimeframe.map((timestamp: BigNumber) => timestamp.toNumber())).to.be.eql(
      options.impactTimeframe,
    );
    expect(claim.impactScopes.map((impactScope: BigNumber) => impactScope.toNumber())).to.be.eql(options.impactScopes);
    expect(claim.rights).to.be.eq(options.rightsID);
  });

  it("parses input data to create hypercert - approach limit", async function () {
    // GAS COST 25_996_892
    const { user, minter } = await setupTest();

    const options = {
      rightsID: 1,
      workTimeframe: [1, 2],
      impactTimeframe: [2, 3],
      contributors: Array(100).fill(user.address),
      workScopes: [...Array(500).keys()],
      impactScopes: [...Array(500).keys()],
      uri: "cillum tempor exercitation cillum minim non proident laboris et pariatur dolore duis sit ad Lorem proident voluptate ex officia nostrud officia do esse deserunt adipisicing excepteur nostrud aliqua qui in amet deserunt laboris nostrud tempor in culpa magna ullamco aliquip enim incididunt occaecat eu officia cupidatat reprehenderit anim aliqua do do nulla sint officia eu elit tempor minim eiusmod proident minim nostrud elit occaecat Lorem irure ex sunt pariatur cupidatat eiusmod dolor ea enim velit incididunt est qui dolore dolore laboris amet aute dolore consequat velit excepteur in enim minim consequat ex nisi ut eiusmod tempor consectetur labore reprehenderit enim",
    };

    const shortdata = await getEncodedImpactClaim(options);

    // TODO generate claimHash of options and validate in test
    const claimHash = "0xe45438c9b8ce52735bf3668be1bb8e0df95cee5f2a4fbbea327dd7f2c6f265da";
    await expect(user.minter.mint(user.address, 0, 1, shortdata))
      .to.emit(minter, "ImpactClaimed")
      .withArgs(
        0,
        claimHash,
        options.contributors,
        options.workTimeframe,
        options.impactTimeframe,
        options.workScopes,
        options.impactScopes,
        options.uri,
      );

    expect(await user.minter.uri(0)).to.be.eq(options.uri);

    const claim = await minter.getImpactCert(claimHash);

    expect(claim.exists).to.be.true;
    expect(claim.version).to.be.eq(0);

    expect(claim.workTimeframe.map((timestamp: BigNumber) => timestamp.toNumber())).to.be.eql(options.workTimeframe);
    expect(claim.workScopes.map((scopeID: BigNumber) => scopeID.toNumber())).to.be.eql(options.workScopes);
    expect(claim.impactTimeframe.map((timestamp: BigNumber) => timestamp.toNumber())).to.be.eql(
      options.impactTimeframe,
    );
    expect(claim.impactScopes.map((impactScope: BigNumber) => impactScope.toNumber())).to.be.eql(options.impactScopes);
    expect(claim.rights).to.be.eq(options.rightsID);
  });
}
