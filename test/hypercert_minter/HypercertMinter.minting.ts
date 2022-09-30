import { faker } from "@faker-js/faker";
import { expect } from "chai";
import { ethers } from "hardhat";

import setupTest, { setupImpactScopes, setupWorkScopes } from "../setup";
import {
  compareClaimAgainstInput,
  encodeClaim,
  getClaimHash,
  getClaimSlotID,
  getEncodedImpactClaim,
  newClaim,
  randomScopes,
} from "../utils";
import { Rights, WorkScopes } from "../wellKnown";

export function shouldBehaveLikeHypercertMinterMinting(): void {
  it("anybody can mint an impact claim with 1 or more fractions - except zero-address", async function () {
    const { deployer, minter } = await setupTest();

    const workScopes = Object.keys(WorkScopes);
    const claim1 = await newClaim({ workScopes: workScopes.slice(0, 1), fractions: [100] });
    const data1 = encodeClaim(claim1);
    const hash = await getClaimHash(claim1);
    const claimID = await getClaimSlotID(claim1);
    const data2 = await getEncodedImpactClaim({ workTimeframe: [234567890, 123456789] });
    const data3 = await getEncodedImpactClaim({ impactTimeframe: [1087654321, 987654321] });
    const data4 = await getEncodedImpactClaim({ impactTimeframe: [108765432, 109999432] });

    // Empty data
    await expect(deployer.minter.mint(deployer.address, "0x")).to.be.revertedWith("_parseData: input data empty");
    // Invalid workTimeframe
    await expect(deployer.minter.mint(deployer.address, data2)).to.be.revertedWith("Mint: invalid workTimeframe");
    // Invalid impactTimeframe
    await expect(deployer.minter.mint(deployer.address, data3)).to.be.revertedWith("Mint: invalid impactTimeframe");
    // Invalid impactTimeframe
    await expect(deployer.minter.mint(deployer.address, data4)).to.be.revertedWith(
      "Mint: impactTimeframe prior to workTimeframe",
    );

    await expect(minter.ownerOf(1)).to.be.revertedWith("ERC721: invalid token ID");
    await expect(minter.slotOf(1)).to.be.revertedWith("ERC3525: slot query for nonexistent token");
    await expect(minter["balanceOf(uint256)"](1)).to.be.revertedWith("ERC3525: balance query for nonexistent token");

    // Supply 100, 1 fraction, single slot
    await expect(deployer.minter.mint(deployer.address, data1))
      .to.emit(minter, "Transfer")
      .withArgs(ethers.constants.AddressZero, deployer.address, 1)
      .to.emit(minter, "SlotChanged")
      .withArgs(1, 0, claimID)
      .to.emit(minter, "ImpactClaimed")
      .withArgs(claimID, deployer.address, claim1.fractions);

    expect(await minter.ownerOf(1)).to.be.eq(deployer.address);
    expect(await minter.slotOf(1)).to.be.eq(claimID);
    expect(await minter.tokenSupplyInSlot(claimID)).to.be.eq(1);

    expect(await minter["balanceOf(uint256)"](1)).to.be.eq("100");
    expect(await minter.tokenURI(1)).to.include("data:application/json;");
    expect(await minter.slotURI(claimID)).to.include("data:application/json;");

    await expect(deployer.minter.mint(ethers.constants.AddressZero, data1)).to.be.revertedWith(
      "Mint: mint to the zero address",
    );
  });

  it("anybody can mint an impact claim with multiple fractions - except zero-address", async function () {
    const { deployer, minter, user } = await setupTest();

    const workScopes = Object.keys(WorkScopes);
    const claim = await newClaim({ workScopes: workScopes.slice(1, 2), fractions: [50, 50] });
    const data = encodeClaim(claim);
    const claimID = await getClaimSlotID(claim);

    // Supply 100, 2 fractions, single slot
    await expect(user.minter.mint(user.address, data))
      .to.emit(minter, "Transfer")
      .withArgs(ethers.constants.AddressZero, user.address, 1)
      .to.emit(minter, "Transfer")
      .withArgs(ethers.constants.AddressZero, user.address, 2)
      .to.emit(minter, "SlotChanged")
      .withArgs(1, 0, claimID)
      .to.emit(minter, "SlotChanged")
      .withArgs(2, 0, claimID);

    expect(await minter.ownerOf(1)).to.be.eq(user.address);
    expect(await minter.ownerOf(2)).to.be.eq(user.address);

    expect(await minter.tokenSupplyInSlot(claimID)).to.be.eq(2);

    expect(await minter.slotOf(1)).to.be.eq(claimID);
    expect(await minter.slotOf(2)).to.be.eq(claimID);

    expect(await minter.tokenInSlotByIndex(claimID, 0)).to.be.eq(1);
    expect(await minter.tokenInSlotByIndex(claimID, 1)).to.be.eq(2);

    expect(await minter["balanceOf(uint256)"](1)).to.be.eq("50");
    expect(await minter["balanceOf(uint256)"](1)).to.be.eq("50");

    await expect(deployer.minter.mint(ethers.constants.AddressZero, data)).to.be.revertedWith(
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

  it("allows for dynamic URIs which are consistent for all tokens in a slot", async function () {
    const { user, minter } = await setupTest();

    const claim = await newClaim({ uri: "Test 1234", fractions: [50, 50] });
    const shortdata = await getEncodedImpactClaim(claim);
    const claimID = await getClaimSlotID(claim);

    await expect(user.minter.mint(user.address, shortdata))
      .to.emit(minter, "Transfer")
      .withArgs(ethers.constants.AddressZero, user.address, 1)
      .to.emit(minter, "Transfer")
      .withArgs(ethers.constants.AddressZero, user.address, 2);

    expect(await user.minter.tokenURI(1))
      .to.include("data:application/json;")
      .to.include(claim.uri);
    expect(await user.minter.tokenURI(2))
      .to.include("data:application/json;")
      .to.include(claim.uri);
    expect(await user.minter.slotURI(claimID))
      .to.include("data:application/json;")
      .to.include(claim.uri);

    const cid = "ipfs://QmW2WQi7j6c7UgJTarActp7tDNikE4B2qXtFCfLPdsgaTQ/cat.jpg";

    const claim2 = await newClaim({ ...claim, workTimeframe: [12345678, 87654321], uri: cid, fractions: [50, 50] });
    const claimID2 = await getClaimSlotID(claim2);

    const data2 = await getEncodedImpactClaim(claim2);

    await expect(user.minter.mint(user.address, data2))
      .to.emit(minter, "Transfer")
      .withArgs(ethers.constants.AddressZero, user.address, 3);

    expect(await user.minter.tokenURI(3))
      .to.include("data:application/json;")
      .to.include(cid);
    expect(await user.minter.slotURI(claimID2))
      .to.include("data:application/json;")
      .to.include(cid);
  });

  it("parses input data to create hypercert - minimal", async function () {
    const { user, minter } = await setupTest();

    const options = {
      name: "Test minimal",
      description: "Light load testing",
      rights: Object.keys(Rights),
      workTimeframe: [1, 2],
      impactTimeframe: [2, 3],
      contributors: [user.address],
      workScopes: [] as string[],
      impactScopes: [] as string[],
      uri: "ipfs://QmW2WQi7j6c7UgJTarActp7tDNikE4B2qXtFCfLPdsgaTQ/",
      version: 0,
      fractions: [100],
    };

    const claim = await newClaim(options);
    const shortdata = await getEncodedImpactClaim(claim);
    const hash = await getClaimHash(claim);
    const claimID = await getClaimSlotID(claim);

    await expect(user.minter.mint(user.address, shortdata))
      .to.emit(minter, "ImpactClaimed")
      .withArgs(claimID, user.address, claim.fractions);

    expect(await minter.tokenURI(1))
      .to.include("data:application/json;")
      .to.include(options.uri);
    expect(await minter.slotURI(claimID))
      .to.include("data:application/json;")
      .to.include(options.uri);
    expect(await minter.tokenSupplyInSlot(claimID)).to.be.eq(1);

    const hypercert = await minter.getImpactCert(claimID);

    expect(hypercert.exists).to.be.true;

    await compareClaimAgainstInput(hypercert, options);
  });

  it("parses input data to create hypercert - medium", async function () {
    const { user, minter } = await setupTest();

    const impactScopes = randomScopes(50);
    const workScopes = randomScopes(50);
    const options = {
      name: "Test medium",
      description: "Medium load testing",
      rights: Object.keys(Rights),
      workTimeframe: [1, 2],
      impactTimeframe: [2, 3],
      contributors: [user.address],
      impactScopes: Object.keys(impactScopes),
      workScopes: Object.keys(workScopes),
      uri: "ipfs://QmW2WQi7j6c7UgJTarActp7tDNikE4B2qXtFCfLPdsgaTQ/",
      version: 0,
      fractions: new Array(25).fill(50),
    };

    await setupImpactScopes(minter, user.minter, impactScopes);
    await setupWorkScopes(minter, user.minter, workScopes);

    const claim = await newClaim(options);
    const shortdata = await getEncodedImpactClaim(claim);
    const hash = await getClaimHash(claim);
    const claimID = await getClaimSlotID(claim);

    await expect(user.minter.mint(user.address, shortdata))
      .to.emit(minter, "ImpactClaimed")
      .withArgs(claimID, user.address, claim.fractions);

    expect(await minter.tokenURI(1))
      .to.include("data:application/json;")
      .to.include(options.uri);
    expect(await minter.tokenURI(25))
      .to.include("data:application/json;")
      .to.include(options.uri);
    expect(await minter.slotURI(claimID))
      .to.include("data:application/json;")
      .to.include(options.uri);
    expect(await minter.tokenSupplyInSlot(claimID)).to.be.eq(25);

    const hypercert = await minter.getImpactCert(claimID);

    expect(hypercert.exists).to.be.true;

    await compareClaimAgainstInput(hypercert, options);
  });

  it("parses input data to create hypercert - high", async function () {
    const { user, minter } = await setupTest();

    const contributors: string[] = [];
    Array.from({ length: 10 }).forEach(() => contributors.push(faker.finance.ethereumAddress()));

    const impactScopes = randomScopes(100);
    const workScopes = randomScopes(100);
    const options = {
      name: "Test high",
      description: "High load testing",
      rights: Object.keys(Rights),
      workTimeframe: [1, 2],
      impactTimeframe: [2, 3],
      contributors,
      impactScopes: Object.keys(impactScopes),
      workScopes: Object.keys(workScopes),
      uri: "ipfs://test",
      version: 0,
      fractions: new Array(100).fill(50),
    };

    await setupImpactScopes(minter, user.minter, impactScopes);
    await setupWorkScopes(minter, user.minter, workScopes);

    const claim = await newClaim(options);
    const shortdata = await getEncodedImpactClaim(claim);
    const hash = await getClaimHash(claim);
    const claimID = await getClaimSlotID(claim);

    await expect(user.minter.mint(user.address, shortdata)).to.emit(minter, "ImpactClaimed");

    expect(await minter.tokenSupplyInSlot(claimID)).to.be.eq(100);
    expect(await minter.tokenURI(1))
      .to.include("data:application/json;")
      .to.include(options.uri);
    expect(await minter.tokenURI(100))
      .to.include("data:application/json;")
      .to.include(options.uri);
    expect(await minter.slotURI(claimID))
      .to.include("data:application/json;")
      .to.include(options.uri);

    const hypercert = await minter.getImpactCert(claimID);

    expect(hypercert.exists).to.be.true;

    await compareClaimAgainstInput(hypercert, options);
  });

  it("parses input data to create hypercert - approach limit", async function () {
    // GAS COST 28_285_127
    const { user, minter } = await setupTest();

    const contributors: string[] = [];
    Array.from({ length: 25 }).forEach(() => contributors.push(faker.finance.ethereumAddress()));

    const impactScopes = randomScopes(250);
    const workScopes = randomScopes(250);
    const options = {
      name: "Test high",
      description: "High load testing",
      rights: Object.keys(Rights),
      workTimeframe: [1, 2],
      impactTimeframe: [2, 3],
      contributors,
      impactScopes: Object.keys(impactScopes),
      workScopes: Object.keys(workScopes),
      // uri: "cillum tempor exercitation cillum minim non proident laboris et pariatur dolore duis sit ad Lorem proident voluptate ex officia nostrud officia do esse deserunt adipisicing excepteur nostrud aliqua qui in amet deserunt laboris nostrud tempor in culpa magna ullamco aliquip enim incididunt occaecat eu officia cupidatat reprehenderit anim aliqua do do nulla sint officia eu elit tempor minim eiusmod proident minim nostrud elit occaecat Lorem irure ex sunt pariatur cupidatat eiusmod dolor ea enim velit incididunt est qui dolore dolore laboris amet aute dolore consequat velit excepteur in enim minim consequat ex nisi ut eiusmod tempor consectetur labore reprehenderit enim",
      uri: "cillum tempor exercitation cillum minim non proident laboris et pariatur dolore duis sit ad Lorem proident voluptate ex officia nostrud officia do esse deserunt adipisicing excepteur nostrud aliqua qui in amet deserunt laboris nostrud tempor in culpa",
      version: 0,
      fractions: new Array(100).fill(50),
    };

    await setupImpactScopes(minter, user.minter, impactScopes);
    await setupWorkScopes(minter, user.minter, workScopes);

    const claim = await newClaim(options);
    const shortdata = await getEncodedImpactClaim(claim);
    const hash = await getClaimHash(claim);
    const claimID = await getClaimSlotID(claim);

    await expect(user.minter.mint(user.address, shortdata)).to.emit(minter, "ImpactClaimed");

    expect(await minter.tokenSupplyInSlot(claimID)).to.be.eq(100);
    expect(await minter.tokenURI(1))
      .to.include("data:application/json;")
      .to.include(options.uri);
    expect(await minter.tokenURI(100))
      .to.include("data:application/json;")
      .to.include(options.uri);
    expect(await minter.slotURI(claimID))
      .to.include("data:application/json;")
      .to.include(options.uri);

    const hypercert = await minter.getImpactCert(claimID);

    expect(hypercert.exists).to.be.true;

    await compareClaimAgainstInput(hypercert, options);
  });
}
