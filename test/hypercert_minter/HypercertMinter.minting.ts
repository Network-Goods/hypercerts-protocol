import { faker } from "@faker-js/faker";
import { expect } from "chai";
import { ethers } from "hardhat";

import setupTest, { setupImpactScopes, setupWorkScopes } from "../setup";
import { compareClaimAgainstInput, getClaimHash, getEncodedImpactClaim, randomScopes } from "../utils";
import { Rights, WorkScopes } from "../wellKnown";

export function shouldBehaveLikeHypercertMinterMinting(): void {
  it("anybody can mint a token with supply 1 or higher - except zero-address", async function () {
    const { anon, deployer, minter, user } = await setupTest();

    const workScopes = Object.keys(WorkScopes);
    const data1 = await getEncodedImpactClaim({ workScopes: workScopes.slice(0, 1) });
    const data2 = await getEncodedImpactClaim({ workScopes: workScopes.slice(1, 2) });
    const data3 = await getEncodedImpactClaim({ workScopes: workScopes.slice(2, 3) });
    const data4 = await getEncodedImpactClaim();

    // Empty data
    await expect(deployer.minter.mint(deployer.address, 1, "0x")).to.be.revertedWith("Parse: input data empty");

    // Supply 1, multiple users/ids
    await expect(deployer.minter.mint(deployer.address, 1, data1))
      .to.emit(minter, "TransferSingle")
      .withArgs(deployer.address, ethers.constants.AddressZero, deployer.address, 0, 1);
    await expect(user.minter.mint(user.address, 1, data2))
      .to.emit(minter, "TransferSingle")
      .withArgs(user.address, ethers.constants.AddressZero, user.address, 1, 1);
    await expect(anon.minter.mint(anon.address, 1, data3))
      .to.emit(minter, "TransferSingle")
      .withArgs(anon.address, ethers.constants.AddressZero, anon.address, 2, 1);

    // Supply >1
    await expect(deployer.minter.mint(deployer.address, 100_000, data4))
      .to.emit(minter, "TransferSingle")
      .withArgs(deployer.address, ethers.constants.AddressZero, deployer.address, 3, 100_000);

    await expect(deployer.minter.mint(ethers.constants.AddressZero, 1, data1)).to.be.revertedWith(
      "Mint: mint to the zero address",
    );
  });

  //TODO can supply of token be increased? Either remove ID as input, or only allow creator to mint more of same token
  it("an already minted claim (work, impact, creators) cannot be minted again", async function () {
    const { user, minter } = await setupTest();

    const data = await getEncodedImpactClaim();

    await expect(user.minter.mint(user.address, 1, data))
      .to.emit(minter, "TransferSingle")
      .withArgs(user.address, ethers.constants.AddressZero, user.address, 0, 1);

    await expect(user.minter.mint(user.address, 1, data)).to.be.revertedWith("Claim: claim for creators overlapping");

    const workScopes = Object.keys(WorkScopes);
    const otherData = await getEncodedImpactClaim({ workScopes: [workScopes[1], workScopes[2]] });

    await expect(user.minter.mint(user.address, 1, otherData))
      .to.emit(minter, "TransferSingle")
      .withArgs(user.address, ethers.constants.AddressZero, user.address, 1, 1);
  });

  it("claim can not have overlapping contributors", async function () {
    const { user, minter } = await setupTest();

    const contributors: string[] = [];
    Array.from({ length: 3 }).forEach(() => contributors.push(faker.finance.ethereumAddress()));

    const data = await getEncodedImpactClaim({ contributors: contributors });

    await expect(user.minter.mint(user.address, 1, data)).to.emit(minter, "ImpactClaimed");

    const overlappingData = await getEncodedImpactClaim({ contributors: [user.address, contributors[0]] });

    await expect(user.minter.mint(user.address, 1, overlappingData)).to.be.revertedWith(
      "Claim: claim for creators overlapping",
    );
  });

  it("allows for dynamic URIs", async function () {
    const { user, minter } = await setupTest();

    const shortdata = await getEncodedImpactClaim({ uri: "Test 1234" });

    await expect(user.minter.mint(user.address, 1, shortdata))
      .to.emit(minter, "TransferSingle")
      .withArgs(user.address, ethers.constants.AddressZero, user.address, 0, 1);

    expect(await user.minter.uri(0)).to.be.eq("Test 1234");

    const cid = "ipfs://QmW2WQi7j6c7UgJTarActp7tDNikE4B2qXtFCfLPdsgaTQ/cat.jpg";

    const workScopes = Object.keys(WorkScopes);
    const dataWithIPFS = await getEncodedImpactClaim({
      workScopes: [workScopes[0], workScopes[1]],
      uri: cid,
    });

    await expect(user.minter.mint(user.address, 1, dataWithIPFS))
      .to.emit(minter, "TransferSingle")
      .withArgs(user.address, ethers.constants.AddressZero, user.address, 1, 1);

    expect(await user.minter.uri(1)).to.be.eq(cid);
  });

  it("parses input data to create hypercert - minimal", async function () {
    const { user, minter } = await setupTest();

    const options = {
      rights: Object.keys(Rights),
      workTimeframe: [1, 2],
      impactTimeframe: [2, 3],
      contributors: [user.address],
      workScopes: [] as string[],
      impactScopes: [] as string[],
      uri: "ipfs://test",
      version: 0,
    };

    const shortdata = await getEncodedImpactClaim(options);
    const hash = await getClaimHash(options);

    await expect(user.minter.mint(user.address, 1, shortdata))
      .to.emit(minter, "ImpactClaimed")
      .withArgs(
        0,
        hash,
        options.contributors,
        options.workTimeframe,
        options.impactTimeframe,
        options.workScopes,
        options.impactScopes,
        options.rights,
        options.version,
        options.uri,
      );

    expect(await user.minter.uri(0)).to.be.eq(options.uri);

    const claim = await minter.getImpactCert(0);

    expect(claim.exists).to.be.true;

    await compareClaimAgainstInput(claim, options);
  });

  it("parses input data to create hypercert - medium", async function () {
    const { user, minter } = await setupTest();

    const impactScopes = randomScopes(50);
    const workScopes = randomScopes(50);
    const options = {
      rights: Object.keys(Rights),
      workTimeframe: [1, 2],
      impactTimeframe: [2, 3],
      contributors: [user.address],
      impactScopes: Object.keys(impactScopes),
      workScopes: Object.keys(workScopes),
      uri: "ipfs://test",
      version: 0,
    };

    await setupImpactScopes(minter, user.minter, impactScopes);
    await setupWorkScopes(minter, user.minter, workScopes);

    const shortdata = await getEncodedImpactClaim(options);
    const hash = await getClaimHash(options);

    await expect(user.minter.mint(user.address, 1, shortdata))
      .to.emit(minter, "ImpactClaimed")
      .withArgs(
        0,
        hash,
        options.contributors,
        options.workTimeframe,
        options.impactTimeframe,
        options.workScopes,
        options.impactScopes,
        options.rights,
        options.version,
        options.uri,
      );

    expect(await user.minter.uri(0)).to.be.eq(options.uri);

    const claim = await minter.getImpactCert(0);

    expect(claim.exists).to.be.true;

    await compareClaimAgainstInput(claim, options);
  });

  it("parses input data to create hypercert - high", async function () {
    const { user, minter } = await setupTest();

    const contributors: string[] = [];
    Array.from({ length: 10 }).forEach(() => contributors.push(faker.finance.ethereumAddress()));

    const impactScopes = randomScopes(100);
    const workScopes = randomScopes(100);
    const options = {
      rights: Object.keys(Rights),
      workTimeframe: [1, 2],
      impactTimeframe: [2, 3],
      contributors,
      impactScopes: Object.keys(impactScopes),
      workScopes: Object.keys(workScopes),
      uri: "ipfs://test",
      version: 0,
    };

    await setupImpactScopes(minter, user.minter, impactScopes);
    await setupWorkScopes(minter, user.minter, workScopes);

    const shortdata = await getEncodedImpactClaim(options);

    await expect(user.minter.mint(user.address, 1, shortdata)).to.emit(minter, "ImpactClaimed");

    expect(await user.minter.uri(0)).to.be.eq(options.uri);

    const claim = await minter.getImpactCert(0);

    expect(claim.exists).to.be.true;

    await compareClaimAgainstInput(claim, options);
  });

  it("parses input data to create hypercert - approach limit", async function () {
    // GAS COST 28_285_127
    const { user, minter } = await setupTest();

    const contributors: string[] = [];
    Array.from({ length: 100 }).forEach(() => contributors.push(faker.finance.ethereumAddress()));

    const impactScopes = randomScopes(500);
    const workScopes = randomScopes(500);
    const options = {
      rights: Object.keys(Rights),
      workTimeframe: [1, 2],
      impactTimeframe: [2, 3],
      contributors,
      impactScopes: Object.keys(impactScopes),
      workScopes: Object.keys(workScopes),
      uri: "cillum tempor exercitation cillum minim non proident laboris et pariatur dolore duis sit ad Lorem proident voluptate ex officia nostrud officia do esse deserunt adipisicing excepteur nostrud aliqua qui in amet deserunt laboris nostrud tempor in culpa magna ullamco aliquip enim incididunt occaecat eu officia cupidatat reprehenderit anim aliqua do do nulla sint officia eu elit tempor minim eiusmod proident minim nostrud elit occaecat Lorem irure ex sunt pariatur cupidatat eiusmod dolor ea enim velit incididunt est qui dolore dolore laboris amet aute dolore consequat velit excepteur in enim minim consequat ex nisi ut eiusmod tempor consectetur labore reprehenderit enim",
      version: 0,
    };

    await setupImpactScopes(minter, user.minter, impactScopes);
    await setupWorkScopes(minter, user.minter, workScopes);

    const shortdata = await getEncodedImpactClaim(options);

    await expect(user.minter.mint(user.address, 1, shortdata)).to.emit(minter, "ImpactClaimed");

    expect(await user.minter.uri(0)).to.be.eq(options.uri);

    const claim = await minter.getImpactCert(0);

    expect(claim.exists).to.be.true;

    await compareClaimAgainstInput(claim, options);
  });
}
