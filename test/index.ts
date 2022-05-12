import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";

const parseUnits = ethers.utils.parseUnits;

describe("Test", function () {
    let owner: SignerWithAddress, other: SignerWithAddress;

    this.beforeEach(async function () {
        [owner, other] = await ethers.getSigners();
    });

    it("Test 1", async function () {});
});
