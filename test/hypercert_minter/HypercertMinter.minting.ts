import { faker } from "@faker-js/faker";
import { expect } from "chai";
import { ethers } from "hardhat";

import setupTest, { setupImpactScopes, setupWorkScopes } from "../setup";
import {
  compareClaimAgainstInput,
  encodeClaim,
  getClaimHash,
  getEncodedImpactClaim,
  newClaim,
  randomScopes,
} from "../utils";
import { Rights, WorkScopes } from "../wellKnown";

export function shouldBehaveLikeHypercertMinterMinting(): void {
  it("anybody can mint a token with supply 1 or higher - except zero-address", async function () {
    const { anon, deployer, minter, user } = await setupTest();

    const workScopes = Object.keys(WorkScopes);
    const claim1 = await newClaim({ workScopes: workScopes.slice(0, 1) });
    const data1 = encodeClaim(claim1);
    const hash1 = await getClaimHash(claim1);
    const claim2 = await newClaim({ workScopes: workScopes.slice(1, 2) });
    const data2 = encodeClaim(claim2);
    const hash2 = await getClaimHash(claim2);
    const claim3 = await newClaim({ workScopes: workScopes.slice(2, 3) });
    const data3 = encodeClaim(claim3);
    const hash3 = await getClaimHash(claim3);
    const claim4 = await newClaim();
    const data4 = encodeClaim(claim4);
    const hash4 = await getClaimHash(claim4);
    const data5 = await getEncodedImpactClaim({ workTimeframe: [234567890, 123456789] });
    const data6 = await getEncodedImpactClaim({ impactTimeframe: [1087654321, 987654321] });
    const data7 = await getEncodedImpactClaim({ impactTimeframe: [108765432, 109999432] });

    // Empty data
    await expect(deployer.minter.mint(deployer.address, "0x")).to.be.revertedWith("_parseData: input data empty");
    // Invalid workTimeframe
    await expect(deployer.minter.mint(deployer.address, data5)).to.be.revertedWith("Mint: invalid workTimeframe");
    // Invalid impactTimeframe
    await expect(deployer.minter.mint(deployer.address, data6)).to.be.revertedWith("Mint: invalid impactTimeframe");
    // Invalid impactTimeframe
    await expect(deployer.minter.mint(deployer.address, data7)).to.be.revertedWith(
      "Mint: impactTimeframe prior to workTimeframe",
    );

    // Supply 1, multiple users/ids
    await expect(deployer.minter.mint(deployer.address, data1))
      .to.emit(minter, "Transfer")
      .withArgs(ethers.constants.AddressZero, deployer.address, 1)
      .to.emit(minter, "SlotChanged")
      .withArgs(1, 0, hash1);
    expect(await user.minter.ownerOf(1)).to.be.eq(deployer.address);
    await expect(user.minter.mint(user.address, data2))
      .to.emit(minter, "Transfer")
      .withArgs(ethers.constants.AddressZero, user.address, 2)
      .to.emit(minter, "SlotChanged")
      .withArgs(2, 0, hash2);
    expect(await user.minter.ownerOf(2)).to.be.eq(user.address);
    await expect(anon.minter.mint(anon.address, data3))
      .to.emit(minter, "Transfer")
      .withArgs(ethers.constants.AddressZero, anon.address, 3)
      .to.emit(minter, "SlotChanged")
      .withArgs(3, 0, hash3);
    expect(await user.minter.ownerOf(3)).to.be.eq(anon.address);

    // Supply >1
    await expect(deployer.minter.mint(deployer.address, data4))
      .to.emit(minter, "Transfer")
      .withArgs(ethers.constants.AddressZero, deployer.address, 4)
      .to.emit(minter, "SlotChanged")
      .withArgs(4, 0, hash4);

    await expect(deployer.minter.mint(ethers.constants.AddressZero, data1)).to.be.revertedWith(
      "Mint: mint to the zero address",
    );
  });

  it("an already minted claim (work, impact, creators) cannot be minted again", async function () {
    const { user, minter } = await setupTest();

    const data = await getEncodedImpactClaim();

    await expect(user.minter.mint(user.address, data))
      .to.emit(minter, "Transfer")
      .withArgs(ethers.constants.AddressZero, user.address, 1);

    await expect(user.minter.mint(user.address, data)).to.be.revertedWith("Claim: claim for creators overlapping");

    const workScopes = Object.keys(WorkScopes);
    const otherData = await getEncodedImpactClaim({ workScopes: [workScopes[1], workScopes[2]] });

    await expect(user.minter.mint(user.address, otherData))
      .to.emit(minter, "Transfer")
      .withArgs(ethers.constants.AddressZero, user.address, 2);
  });

  it("claim can not have overlapping contributors", async function () {
    const { user, minter } = await setupTest();

    const contributors: string[] = [];
    Array.from({ length: 3 }).forEach(() => contributors.push(faker.finance.ethereumAddress()));

    const data = await getEncodedImpactClaim({ contributors: contributors });

    await expect(user.minter.mint(user.address, data)).to.emit(minter, "ImpactClaimed");

    const overlappingData = await getEncodedImpactClaim({ contributors: [user.address, contributors[0]] });

    await expect(user.minter.mint(user.address, overlappingData)).to.be.revertedWith(
      "Claim: claim for creators overlapping",
    );
  });

  it("allows for dynamic URIs", async function () {
    const { user, minter } = await setupTest();

    const shortdata = await getEncodedImpactClaim({ uri: "Test 1234" });

    await expect(user.minter.mint(user.address, shortdata))
      .to.emit(minter, "Transfer")
      .withArgs(ethers.constants.AddressZero, user.address, 1);

    expect(await user.minter.tokenURI(1)).to.be.eq("Test 1234");

    const cid = "ipfs://QmW2WQi7j6c7UgJTarActp7tDNikE4B2qXtFCfLPdsgaTQ/cat.jpg";

    const workScopes = Object.keys(WorkScopes);
    const dataWithIPFS = await getEncodedImpactClaim({
      workScopes: [workScopes[0], workScopes[1]],
      uri: cid,
    });

    await expect(user.minter.mint(user.address, dataWithIPFS))
      .to.emit(minter, "Transfer")
      .withArgs(ethers.constants.AddressZero, user.address, 2);

    expect(await user.minter.tokenURI(2)).to.be.eq(cid);
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

    await expect(user.minter.mint(user.address, shortdata))
      .to.emit(minter, "ImpactClaimed")
      .withArgs(
        1,
        user.address,
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

    expect(await user.minter.tokenURI(1)).to.be.eq(options.uri);

    const claim = await minter.getImpactCert(1);

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

    await expect(user.minter.mint(user.address, shortdata))
      .to.emit(minter, "ImpactClaimed")
      .withArgs(
        1,
        user.address,
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

    expect(await user.minter.tokenURI(1)).to.be.eq(options.uri);

    const claim = await minter.getImpactCert(1);

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

    await expect(user.minter.mint(user.address, shortdata)).to.emit(minter, "ImpactClaimed");

    expect(await user.minter.tokenURI(1)).to.be.eq(options.uri);

    const claim = await minter.getImpactCert(1);

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

    await expect(user.minter.mint(user.address, shortdata)).to.emit(minter, "ImpactClaimed");

    expect(await user.minter.tokenURI(1)).to.be.eq(options.uri);

    const claim = await minter.getImpactCert(1);

    expect(claim.exists).to.be.true;

    await compareClaimAgainstInput(claim, options);
  });
}
