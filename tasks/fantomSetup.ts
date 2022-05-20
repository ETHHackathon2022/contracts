import { task } from "hardhat/config";
import chalk from "chalk";
import { Registry, ERC20Mock } from "../typechain-types";

function writeStartLine(text: string) {
    const blankSpace = Array(100)
        .map(() => " ")
        .join(" ");
    process.stdout.write("\r" + blankSpace + "\r" + chalk.blue(text));
}

function writeStep(text = "") {
    writeStartLine("Setting up: " + text);
}

task("fantomSetup", "Setup initial contracts (for Fantom)").setAction(
    async function ({ _ }, { run, ethers: { getContract, getContractAt } }) {
        writeStartLine("Starting set up...");

        // Whitelist tokens

        writeStep("whitelisting tokens");

        const registry = await getContract<Registry>("Registry");

        const tokenAddresses = [
            "0x049d68029688eabf473097a2fc38ef61633a3c7a", // USDT
            "0x04068DA6C83AFCFA0e13ba15A6696662335D5B75", // USDC
            "0x8D11eC38a3EB5E956B052f67Da8Bdc9bef8Abf3E", // DAI
        ];

        const tokens = await Promise.all(
            tokenAddresses.map(async (a) => {
                return await getContractAt<ERC20Mock>("ERC20Mock", a);
            })
        );

        for (let token of tokens) {
            writeStep(`whitelisting ${await token.name()}`);
            const wTx = await registry.setTokenWhitelisted(token.address, true);
            await wTx.wait();
        }

        // Swap data

        writeStep("setting default uniswapv2 router");

        const uniswapRouter = "0xf491e7b69e4244ad4002bc14e878a34207e38c29"; // SpookySwap

        const tx = await registry.setDefaultUniswapV2Router(uniswapRouter);
        await tx.wait();

        // Set pipelines
        writeStep("adding pipelines");

        // Pure Pipeline

        writeStep("adding pure pipeline");

        const purePipeline = await getContract("PurePipeline");

        const vaults = tokens;
        for (let vault of vaults) {
            writeStep(`adding for vault ${await vault.name()}`);
            const tx1 = await registry.setVaultPipeline(
                vault.address,
                purePipeline.address
            );
            await tx1.wait();
        }

        // Aave Pipeline

        writeStep("adding aave v3 pipeline");

        const aTokens = [
            "0x6ab707Aca953eDAeFBc4fD23bA73294241490620", // aUSDT
            "0x625E7708f30cA75bfd92586e17077590C60eb4cD", // aUSDC
            "0x82E64f49Ed5EC1bC6e43DAD4FC8Af9bb3A2312EE", // aDAI
        ];

        const aaveV3Pipeline = await getContract("AaveV3Pipeline");

        for (let aToken of aTokens) {
            writeStep(`adding for aave v3 - ${aToken}`);
            const tx1 = await registry.setVaultPipeline(
                aToken,
                aaveV3Pipeline.address
            );
            await tx1.wait();
        }

        // Yearn Single Token Pipeline

        writeStep("adding yearn single token pipeline");

        const yearnVaults = [
            "0x148c05caf1Bb09B5670f00D511718f733C54bC4c", // USDT
            "0xEF0210eB96c7EB36AF8ed1c20306462764935607", // USDC
            "0x637eC617c86D24E421328e6CAEa1d92114892439", // DAI
        ];

        const yearnSingleTokenPipeline = await getContract(
            "YearnSingleTokenPipeline"
        );

        for (let yearnVault of yearnVaults) {
            writeStep(`adding for yearn single token - ${yearnVault}`);
            const tx1 = await registry.setVaultPipeline(
                yearnVault,
                yearnSingleTokenPipeline.address
            );
            await tx1.wait();
        }

        // Finish
        writeStartLine("Setup complete\n");
    }
);
