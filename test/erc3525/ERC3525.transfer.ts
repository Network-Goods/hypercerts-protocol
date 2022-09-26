export function shouldBehaveLikeSemiFungibleTokenTransfer(): void {
  describe("ERC3525 supports transfers on slot and token level"),
    function () {
      it("allows for minting NFTs with identical slots", async function () {
        const { anon, minter } = await setupTest({ workScopes: {} });
        await setupWorkScopes(anon.minter, minter);

        expect(await minter.workScopes(Object.keys(WorkScopes)[0])).to.be.eq("clean-air-tech");
        expect(await minter.workScopes(Object.keys(WorkScopes)[1])).to.be.eq("education");
        expect(await minter.workScopes(Object.keys(WorkScopes)[2])).to.be.eq("tree-planting");
        expect(await minter.workScopes(Object.keys(WorkScopes)[3])).to.be.eq("waterway-cleaning");
      });
    };
}
