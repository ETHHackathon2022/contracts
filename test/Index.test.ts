import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { ERC20Mock, Factory, Registry } from "../typechain";
import { setupContracts } from "./shared/setupContracts";

const { MaxUint256 } = ethers.constants;
const { parseUnits } = ethers.utils;

describe("Test Indexes", function () {
    let owner: SignerWithAddress, other: SignerWithAddress;
    let usdc: ERC20Mock,
        usdt: ERC20Mock,
        dai: ERC20Mock,
        registry: Registry,
        factory: Factory;

    this.beforeEach(async function () {
        [owner, other] = await ethers.getSigners();

        ({ usdc, usdt, dai, registry, factory } = await setupContracts());
    });

    it("Buying index", async function () {
        await usdc.mint(owner.address, parseUnits("100", 6));
        await usdc.approve(factory.address, MaxUint256);

        await factory.createIndex(
            "MyIndex",
            "MID",
            [
                { vault: usdc.address },
                { vault: usdt.address },
                { vault: dai.address },
            ],
            [1, 1, 1],
            usdc.address,
            parseUnits("100", 6)
        );
    });
});
