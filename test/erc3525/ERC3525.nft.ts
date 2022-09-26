export function shouldBehaveLikeSemiFungibleToken(): void {
  it("allows for minting NFTs with identical slots", async function () {
    const { anon, minter } = await setupTest({ workScopes: {} });
    await setupWorkScopes(anon.minter, minter);

    expect(await minter.workScopes(Object.keys(WorkScopes)[0])).to.be.eq("clean-air-tech");
    expect(await minter.workScopes(Object.keys(WorkScopes)[1])).to.be.eq("education");
    expect(await minter.workScopes(Object.keys(WorkScopes)[2])).to.be.eq("tree-planting");
    expect(await minter.workScopes(Object.keys(WorkScopes)[3])).to.be.eq("waterway-cleaning");
  });

  it("allows for merging NFTs in identical slots", async function () {
    const { deployer, minter } = await setupTest({ workScopes: {} });
    await setupWorkScopes(deployer.minter, minter);

    for (const text of Object.values(WorkScopes)) {
      await expect(deployer.minter.addWorkScope(text)).to.be.revertedWith("already exists");
    }
  });

  it("should reject empty work scopes", async function () {
    const { user } = await setupTest();

    await expect(user.minter.addWorkScope("")).to.be.revertedWith("empty text");
  });
}
