import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { BigNumberish } from "ethers";
import { ethers } from "hardhat";
import {
    ERC20Mock,
    Factory,
    Registry,
    UniswapRouter,
    Index,
} from "../typechain";
import { setupContracts } from "./shared/setupContracts";
import { both } from "./shared/utils";

const { MaxUint256 } = ethers.constants;
const { parseUnits } = ethers.utils;

async function displayComponents(index: Index, numComponents: number) {
    for (let i = 0; i < numComponents; i++) {
        const vault = await index.components(i);

        const token = await ethers.getContractAt("ERC20Mock", vault);
        console.log(
            (await token.name()) +
                ": " +
                ethers.utils.formatUnits(
                    await token.balanceOf(index.address),
                    await token.decimals()
                )
        );
    }
}

describe("Test Indexes", function () {
    let owner: SignerWithAddress, other: SignerWithAddress;
    let usdc: ERC20Mock,
        usdt: ERC20Mock,
        dai: ERC20Mock,
        busd: ERC20Mock,
        factory: Factory;

    this.beforeEach(async function () {
        [owner, other] = await ethers.getSigners();

        ({ usdc, usdt, dai, busd, factory } = await setupContracts());
    });

    describe("Index with pure tokens", function () {
        let indexName: string,
            indexSymbol: string,
            components: { vault: string }[],
            weights: number[],
            weightsTotal: number,
            buyCurrency: ERC20Mock,
            buyAmount: BigNumberish;
        let index: Index;

        this.beforeEach(async function () {
            indexName = "MyIndex";
            indexSymbol = "MID";
            components = [
                { vault: usdc.address },
                { vault: usdt.address },
                { vault: dai.address },
            ];
            weights = [1, 1, 1];
            weightsTotal = 3;
            buyCurrency = usdc;
            buyAmount = parseUnits("100", 6);

            await usdc.mint(owner.address, parseUnits("100", 6));
            await usdc.approve(factory.address, MaxUint256);

            const { reply } = await both(factory, "createIndex", [
                indexName,
                indexSymbol,
                components,
                weights,
                buyCurrency.address,
                buyAmount,
            ]);
            index = await ethers.getContractAt("Index", reply);
        });

        it("index parameters should be correct", async function () {
            expect(await index.name()).to.equal(indexName);
            expect(await index.symbol()).to.equal(indexSymbol);

            for (let i = 0; i < components.length; i++) {
                expect(await index.components(i)).to.equal(components[i].vault);
            }

            await displayComponents(index, 3);
        });

        it("rebalancing should work", async function () {
            await index.rebalanceComponent(1, 2, 50, 100);

            await displayComponents(index, 3);
        });

        it("removing with rebalancing should work", async function () {
            await index.removeComponent(2);

            await displayComponents(index, 2);
        });

        it("adding with rebalancing should work", async function () {
            await index.addComponentAndRebalance(
                { vault: busd.address },
                0,
                50,
                100
            );

            await displayComponents(index, 4);
        });
    });
});
