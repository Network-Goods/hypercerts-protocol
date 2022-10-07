import { expect } from "chai";
import { ethers, getNamedAccounts } from "hardhat";

import { HyperCertMetadata as Metadata } from "../../src/types";
import { setupTestMetadata } from "../setup";
import { DEFAULT_ADMIN_ROLE, HyperCertMetadata, UPGRADER_ROLE } from "../wellKnown";

describe("Unit tests", function () {
  describe(HyperCertMetadata, function () {
    it("is an initializable contract", async () => {
      const tokenFactory = await ethers.getContractFactory(HyperCertMetadata);
      const tokenInstance = <Metadata>await tokenFactory.deploy();
      const { anon } = await getNamedAccounts();

      await expect(tokenInstance.initialize(anon)).to.be.revertedWith("Initializable: contract is already initialized");
    });

    it("is a UUPS-upgradeable contract", async () => {
      const { sft } = await setupTestMetadata();

      await expect(sft.proxiableUUID()).to.be.revertedWith("UUPSUpgradeable: must not be called through delegatecall");
    });

    const roles = <[string, string][]>[
      ["admin", DEFAULT_ADMIN_ROLE],
      ["upgrader", UPGRADER_ROLE],
    ];

    roles.forEach(([name, role]) => {
      it(`supports ${name} role`, async function () {
        const { sft, user, deployer } = await setupTestMetadata();

        expect(await sft.hasRole(role, deployer.address)).to.be.true;
        expect(await sft.hasRole(role, user.address)).to.be.false;

        await expect(user.sft.grantRole(role, user.address)).to.be.revertedWith(
          `AccessControl: account ${user.address.toLowerCase()} is missing role ${DEFAULT_ADMIN_ROLE}`,
        );

        await expect(deployer.sft.grantRole(role, user.address))
          .to.emit(sft, "RoleGranted")
          .withArgs(role, user.address, deployer.address);
      });
    });
  });
});
