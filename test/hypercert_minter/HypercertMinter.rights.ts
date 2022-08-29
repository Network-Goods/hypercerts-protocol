import { expect } from "chai";

import setupTest, { setupRights } from "../setup";
import { Rights } from "../wellKnown";

export function shouldBehaveLikeHypercertMinterAddingRights(): void {
  it("should allow anyone to add new right", async function () {
    const { anon, minter } = await setupTest({ rights: {} });
    await setupRights(anon.minter, minter);

    expect(await minter.rights(Object.keys(Rights)[0])).to.be.eq("admin");
    expect(await minter.rights(Object.keys(Rights)[1])).to.be.eq("mint");
    expect(await minter.rights(Object.keys(Rights)[2])).to.be.eq("merge");
    expect(await minter.rights(Object.keys(Rights)[3])).to.be.eq("split");
    expect(await minter.rights(Object.keys(Rights)[4])).to.be.eq("burn");
  });

  it("should reject duplicate right", async function () {
    const { deployer, minter } = await setupTest({ rights: {} });
    await setupRights(deployer.minter, minter);

    for (const text of Object.values(Rights)) {
      await expect(deployer.minter.addRight(text)).to.be.revertedWith("addRight: already exists");
    }
  });

  it("should reject empty right", async function () {
    const { user } = await setupTest();

    await expect(user.minter.addRight("")).to.be.revertedWith("addRight: empty text");
  });
}
