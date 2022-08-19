import { expect } from "chai";

import setupTest, { setupImpactScopes, setupWorkScopes } from "../setup";
import { ImpactScopes, WorkScopes } from "../wellKnown";

export function shouldBehaveLikeHypercertMinterAddingImpactScopes(): void {
  it("should allow anyone to add new impact scopes", async function () {
    const { anon, minter } = await setupTest({ impactScopes: {} });
    await setupImpactScopes(anon.minter, minter);
  });

  it("should reject duplicate impact scopes", async function () {
    const { deployer, minter } = await setupTest({ impactScopes: {} });
    await setupImpactScopes(deployer.minter, minter);

    for (const text of Object.values(ImpactScopes)) {
      await expect(deployer.minter.addImpactScope(text)).to.be.revertedWith("addImpactScope: already exists");
    }
  });

  it("should reject empty impact scopes", async function () {
    const { user } = await setupTest();

    await expect(user.minter.addImpactScope("")).to.be.revertedWith("addImpactScope: empty text");
  });
}

export function shouldBehaveLikeHypercertMinterAddingWorkScopes(): void {
  it("should allow anyone to add new work scopes", async function () {
    const { anon, minter } = await setupTest({ workScopes: {} });
    await setupWorkScopes(anon.minter, minter);
  });

  it("should reject duplicate work scopes", async function () {
    const { deployer, minter } = await setupTest({ workScopes: {} });
    await setupWorkScopes(deployer.minter, minter);

    for (const text of Object.values(WorkScopes)) {
      await expect(deployer.minter.addWorkScope(text)).to.be.revertedWith("addWorkScope: already exists");
    }
  });

  it("should reject empty work scopes", async function () {
    const { user } = await setupTest();

    await expect(user.minter.addWorkScope("")).to.be.revertedWith("addWorkScope: empty text");
  });
}
