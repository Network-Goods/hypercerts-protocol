import { expect } from "chai";

import setupTest from "../setup";
import { encodeClaim, newClaim } from "../utils";

export function shouldBehaveLikeHypercertMinterIntegration(): void {
  it("supports the full minting, splitting, merging, burning flow", async function () {
    const { deployer, minter } = await setupTest();
    const claim = await newClaim({ fractions: [100, 200, 300] });
    const data = encodeClaim(claim);

    await expect(deployer.minter.mint(deployer.address, data)).to.emit(minter, "ImpactClaimed");
    await expect(deployer.minter.split(2, [100, 100])).to.emit(minter, "TransferValue");
    expect(await deployer.minter["balanceOf(uint256)"](2)).to.be.eq("100");

    await expect(deployer.minter.merge([2, 3])).to.emit(minter, "TransferValue");
    await expect(deployer.minter["balanceOf(uint256)"](2)).to.be.revertedWith("NonExistentToken");
    expect(await deployer.minter["balanceOf(uint256)"](3)).to.be.eq("400");

    await expect(deployer.minter.split(3, [100, 100, 200])).to.emit(minter, "TransferValue");

    const secondClaim = await newClaim({ workTimeframe: [12345678, 87654321], fractions: [1000, 2000, 3000] });
    const secondData = encodeClaim(secondClaim);

    await expect(deployer.minter.mint(deployer.address, secondData)).to.emit(minter, "ImpactClaimed");
    await expect(deployer.minter.split(7, [500, 500])).to.emit(minter, "TransferValue");
  });
}
