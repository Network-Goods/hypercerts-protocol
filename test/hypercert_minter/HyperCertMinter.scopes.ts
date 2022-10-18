import { expect } from "chai";

import setupTest, { setupImpactScopes, setupWorkScopes } from "../setup";
import { ImpactScopes, WorkScopes } from "../wellKnown";

export function shouldBehaveLikeHyperCertMinterAddingImpactScopes(): void {
  it("should allow anyone to add new impact scopes", async function () {
    const { anon, minter } = await setupTest({ impactScopes: {} });
    await setupImpactScopes(anon.minter, minter);

    expect(await minter.impactScopes(Object.keys(ImpactScopes)[0])).to.be.eq("clean-air");
    expect(await minter.impactScopes(Object.keys(ImpactScopes)[1])).to.be.eq("biodiversity");
    expect(await minter.impactScopes(Object.keys(ImpactScopes)[2])).to.be.eq("pollution-reduction");
    expect(await minter.impactScopes(Object.keys(ImpactScopes)[3])).to.be.eq("top-soil-growth");
  });

  it("should reject duplicate impact scopes", async function () {
    const { deployer, minter } = await setupTest({ impactScopes: {} });
    await setupImpactScopes(deployer.minter, minter);

    for (const text of Object.values(ImpactScopes)) {
      await expect(deployer.minter.addImpactScope(text)).to.be.revertedWith("DuplicateScope");
    }
  });

  it("should reject empty impact scopes", async function () {
    const { user } = await setupTest();

    await expect(user.minter.addImpactScope("")).to.be.revertedWith("EmptyInput");
  });
}

export function shouldBehaveLikeHyperCertMinterAddingWorkScopes(): void {
  it("should allow anyone to add new work scopes", async function () {
    const { anon, minter } = await setupTest({ workScopes: {} });
    await setupWorkScopes(anon.minter, minter);

    expect(await minter.workScopes(Object.keys(WorkScopes)[0])).to.be.eq("clean-air-tech");
    expect(await minter.workScopes(Object.keys(WorkScopes)[1])).to.be.eq("education");
    expect(await minter.workScopes(Object.keys(WorkScopes)[2])).to.be.eq("tree-planting");
    expect(await minter.workScopes(Object.keys(WorkScopes)[3])).to.be.eq("waterway-cleaning");
  });

  it("should reject duplicate work scopes", async function () {
    const { deployer, minter } = await setupTest({ workScopes: {} });
    await setupWorkScopes(deployer.minter, minter);

    for (const text of Object.values(WorkScopes)) {
      await expect(deployer.minter.addWorkScope(text)).to.be.revertedWith("DuplicateScope");
    }
  });

  it("should reject empty work scopes", async function () {
    const { user } = await setupTest();

    await expect(user.minter.addWorkScope("")).to.be.revertedWith("EmptyInput");
  });
}
