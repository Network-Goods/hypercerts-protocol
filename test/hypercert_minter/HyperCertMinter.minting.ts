import { faker } from "@faker-js/faker";
import { expect } from "chai";
import { ethers } from "hardhat";

import setupTest, { setupImpactScopes, setupWorkScopes } from "../setup";
import {
  Claim,
  compareClaimAgainstInput,
  encodeClaim,
  getEncodedImpactClaim,
  newClaim,
  randomScopes,
  subScopeKeysForValues,
  validateMetadata,
} from "../utils";
import { ImpactScopes, Rights, WorkScopes } from "../wellKnown";

export function shouldBehaveLikeHypercertMinterMinting(): void {
  it("should sub values for keys", async () => {
    const claim = await newClaim();
    const subbed = subScopeKeysForValues(claim, ImpactScopes);
    expect(subbed.impactScopes[0]).to.equal("clean-air");
  });

  it("anybody can mint an impact claim with 1 or more fractions - except zero-address", async function () {
    const { deployer, minter } = await setupTest();

    const workScopes = Object.keys(WorkScopes).slice(0, 1);
    const claim1 = await newClaim({
      name: "Impact claim simple minting test",
      workScopes: workScopes,
      fractions: [100],
    });
    const data1 = encodeClaim(claim1);
    const claimID = 1;
    const data2 = await getEncodedImpactClaim({ workTimeframe: [234567890, 123456789] });
    const data3 = await getEncodedImpactClaim({ impactTimeframe: [1087654321, 987654321] });
    const data4 = await getEncodedImpactClaim({ impactTimeframe: [108765432, 109999432] });

    // Empty data
    await expect(deployer.minter.mint(deployer.address, "0x")).to.be.revertedWith("EmptyInput");
    // Invalid workTimeframe
    await expect(deployer.minter.mint(deployer.address, data2)).to.be.revertedWith("InvalidTimeframe");
    // Invalid impactTimeframe
    await expect(deployer.minter.mint(deployer.address, data3)).to.be.revertedWith("InvalidTimeframe");
    // Invalid impactTimeframe
    await expect(deployer.minter.mint(deployer.address, data4)).to.be.revertedWith("InvalidTimeframe");

    await expect(minter.ownerOf(1)).to.be.revertedWith("NonExistentToken");
    await expect(minter.slotOf(1)).to.be.revertedWith("NonExistentToken");
    await expect(minter["balanceOf(uint256)"](1)).to.be.revertedWith("NonExistentToken");

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
    expect(await minter["balanceOf(uint256)"](1)).to.be.eq(100);
    const claim1Subbed = subScopeKeysForValues(claim1, ImpactScopes);
    await validateMetadata(await minter.tokenURI(1), claim1Subbed, claim1.fractions[0]);
    await validateMetadata(await minter.slotURI(claimID), claim1Subbed);

    await expect(deployer.minter.mint(ethers.constants.AddressZero, data1)).to.be.revertedWith("ToZeroAddress");
  });

  it("anybody can mint an impact claim with multiple fractions - except zero-address", async function () {
    const { deployer, minter, user } = await setupTest();

    const workScopes = Object.keys(WorkScopes).slice(1, 2);
    const claim = await newClaim({ workScopes, fractions: [50, 50] });
    const data = encodeClaim(claim);
    const claimID = 1;

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

    await expect(deployer.minter.mint(ethers.constants.AddressZero, data)).to.be.revertedWith("ToZeroAddress");
  });

  it("an already minted claim (work, impact, creators) cannot be minted again", async function () {
    const { user, minter } = await setupTest();

    const data = await getEncodedImpactClaim();

    await expect(user.minter.mint(user.address, data))
      .to.emit(minter, "Transfer")
      .withArgs(ethers.constants.AddressZero, user.address, 1);

    await expect(user.minter.mint(user.address, data)).to.be.revertedWith("ConflictingClaim");

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

    await expect(user.minter.mint(user.address, overlappingData)).to.be.revertedWith("ConflictingClaim");
  });

  it("allows for dynamic URIs which are consistent for all tokens in a slot which are consistent for all tokens in a slot", async function () {
    const { user, minter } = await setupTest();

    const claim = await newClaim({ uri: "Test 1234", fractions: [50, 50] });
    const shortdata = await getEncodedImpactClaim(claim);
    const claimID = 1;

    await expect(user.minter.mint(user.address, shortdata))
      .to.emit(minter, "Transfer")
      .withArgs(ethers.constants.AddressZero, user.address, 1)
      .to.emit(minter, "Transfer")
      .withArgs(ethers.constants.AddressZero, user.address, 2);

    const claimSubbed = subScopeKeysForValues(claim, ImpactScopes);
    await validateMetadata(await minter.tokenURI(1), claimSubbed, claim.fractions[0]);
    await validateMetadata(await minter.tokenURI(2), claimSubbed, claim.fractions[1]);
    await validateMetadata(await minter.slotURI(claimID), claimSubbed);

    const cid = "ipfs://QmW2WQi7j6c7UgJTarActp7tDNikE4B2qXtFCfLPdsgaTQ/cat.jpg";

    const claim2 = await newClaim({ ...claim, workTimeframe: [12345678, 87654321], uri: cid, fractions: [50, 50] });
    const claimID2 = 2;

    const data2 = await getEncodedImpactClaim(claim2);

    await expect(user.minter.mint(user.address, data2))
      .to.emit(minter, "Transfer")
      .withArgs(ethers.constants.AddressZero, user.address, 3);

    const claim2Subbed = subScopeKeysForValues(claim2, ImpactScopes);
    await validateMetadata(await minter.tokenURI(3), claim2Subbed, claim2.fractions[2]);
    await validateMetadata(await minter.slotURI(claimID2), claim2Subbed);
  });

  it("parses input data to create hypercert - minimal", async function () {
    const { user, minter } = await setupTest();

    const impactScopes = randomScopes(1);
    const workScopes = randomScopes(1);
    const options = <Claim>{
      name: "Test minimal",
      description: "Light load testing",
      rights: Object.keys(Rights),
      workTimeframe: [1, 2],
      impactTimeframe: [2, 3],
      contributors: [user.address],
      impactScopes: Object.keys(impactScopes),
      workScopes: Object.keys(workScopes),
      uri: "ipfs://QmW2WQi7j6c7UgJTarActp7tDNikE4B2qXtFCfLPdsgaTQ/",
      version: 0,
      fractions: [100],
    };

    await setupImpactScopes(minter, user.minter, impactScopes);
    await setupWorkScopes(minter, user.minter, workScopes);

    const claim = await newClaim(options);
    const shortdata = await getEncodedImpactClaim(claim);
    const claimID = 1;

    await expect(user.minter.mint(user.address, shortdata))
      .to.emit(minter, "ImpactClaimed")
      .withArgs(claimID, user.address, claim.fractions);

    await validateMetadata(await minter.tokenURI(1), subScopeKeysForValues(claim, impactScopes), claim.fractions[0]);
    await validateMetadata(await minter.slotURI(claimID), subScopeKeysForValues(claim, impactScopes));

    expect(await minter.tokenSupplyInSlot(claimID)).to.be.eq(1);

    const hypercert = await minter.getImpactCert(claimID);

    expect(hypercert.exists).to.be.true;

    await compareClaimAgainstInput(hypercert, claim);
  });

  it("parses input data to create hypercert - medium", async function () {
    const { user, minter } = await setupTest();

    const impactScopes = randomScopes(50);
    const workScopes = randomScopes(50);
    const options = <Claim>{
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
    const claimID = 1;

    await expect(user.minter.mint(user.address, shortdata))
      .to.emit(minter, "ImpactClaimed")
      .withArgs(claimID, user.address, claim.fractions);

    await validateMetadata(await minter.tokenURI(1), subScopeKeysForValues(claim, impactScopes), claim.fractions[0]);
    await validateMetadata(await minter.tokenURI(25), subScopeKeysForValues(claim, impactScopes), claim.fractions[24]);
    await validateMetadata(await minter.slotURI(claimID), subScopeKeysForValues(claim, impactScopes));

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
    const options = <Claim>{
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
      fractions: new Array(50).fill(50),
    };

    await setupImpactScopes(minter, user.minter, impactScopes);
    await setupWorkScopes(minter, user.minter, workScopes);

    const claim = await newClaim(options);
    const shortdata = await getEncodedImpactClaim(claim);
    const claimID = 1;

    await expect(user.minter.mint(user.address, shortdata)).to.emit(minter, "ImpactClaimed");

    expect(await minter.tokenSupplyInSlot(claimID)).to.be.eq(50);

    await validateMetadata(await minter.tokenURI(1), subScopeKeysForValues(claim, impactScopes), claim.fractions[0]);
    await validateMetadata(await minter.tokenURI(50), subScopeKeysForValues(claim, impactScopes), claim.fractions[49]);
    await validateMetadata(await minter.slotURI(claimID), subScopeKeysForValues(claim, impactScopes));

    const hypercert = await minter.getImpactCert(claimID);

    expect(hypercert.exists).to.be.true;

    await compareClaimAgainstInput(hypercert, options);
  });

  it("parses input data to create hypercert - approach limit", async function () {
    // GAS COST 28_285_127
    const { user, minter } = await setupTest();

    const contributors: string[] = [];
    Array.from({ length: 20 }).forEach(() => contributors.push(faker.finance.ethereumAddress()));

    const n = 75;
    const impactScopes = randomScopes(n);
    const workScopes = randomScopes(n);
    const options = <Claim>{
      name: "Test limit",
      description: "Limit load testing",
      rights: Object.keys(Rights),
      workTimeframe: [1, 2],
      impactTimeframe: [2, 3],
      contributors,
      impactScopes: Object.keys(impactScopes),
      workScopes: Object.keys(workScopes),
      uri: "ipfs://test",
      version: 0,
      fractions: new Array(n).fill(50),
    };

    await setupImpactScopes(minter, user.minter, impactScopes);
    await setupWorkScopes(minter, user.minter, workScopes);

    const claim = await newClaim(options);
    const shortdata = await getEncodedImpactClaim(claim);
    const claimID = 1;

    await expect(user.minter.mint(user.address, shortdata)).to.emit(minter, "ImpactClaimed");

    expect(await minter.tokenSupplyInSlot(claimID)).to.be.eq(n);

    const claimSubbed = subScopeKeysForValues(claim, impactScopes);
    await validateMetadata(await minter.tokenURI(1), claimSubbed, claim.fractions[0]);
    await validateMetadata(await minter.tokenURI(n), claimSubbed, claim.fractions[n - 1]);
    await validateMetadata(await minter.slotURI(claimID), claimSubbed);

    const hypercert = await minter.getImpactCert(claimID);

    expect(hypercert.exists).to.be.true;

    await compareClaimAgainstInput(hypercert, options);
  });
}
