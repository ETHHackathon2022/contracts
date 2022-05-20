import { task } from "hardhat/config";
import chalk from "chalk";
import { Registry, PoolMock, YearnFactoryMock } from "../typechain-types";

function writeStartLine(text: string) {
    const blankSpace = Array(100)
        .map(() => " ")
        .join(" ");
    process.stdout.write("\r" + blankSpace + "\r" + chalk.blue(text));
}

function writeStep(text = "") {
    writeStartLine("Setting up: " + text);
}

task("setup", "Setup initial contracts").setAction(async function (
    { _ },
    { run, ethers: { getContract } }
) {
    writeStartLine("Starting set up...");

    // Whitelist tokens

    writeStep("whitelisting tokens");

    const registry = await getContract<Registry>("Registry");

    const tokens = [
        await getContract("USDC"),
        await getContract("USDT"),
        await getContract("DAI"),
        await getContract("BUSD"),
    ];

    for (let token of tokens) {
        writeStep(`whitelisting ${await token.name()}`);
        const wTx = await registry.setTokenWhitelisted(token.address, true);
        await wTx.wait();
    }

    // Add liquidity to all default pairs
    writeStep("adding liquidity");

    const amountToAdd = "10000000";
    for (let i = 0; i < tokens.length; i++) {
        for (let j = i + 1; j < tokens.length; j++) {
            writeStep(`adding liquidity to pair ${i}-${j}`);

            await run("addLiquidity", {
                tokenA: tokens[i].address,
                tokenB: tokens[j].address,
                amountA: amountToAdd,
                amountB: amountToAdd,
            });
        }
    }

    // Swap data

    writeStep("setting default uniswapv2 router");

    const uniswapRouter = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";

    const tx = await registry.setDefaultUniswapV2Router(uniswapRouter);
    await tx.wait();

    // Aave V3 Mock

    writeStep("configuring aave v3 mock");

    const aavePool = await getContract<PoolMock>("AaveV3Pool");

    for (let token of tokens) {
        const aaveTx = await aavePool.addAsset(token.address);
        await aaveTx.wait();
    }

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

    const aaveV3Pipeline = await getContract("AaveV3Pipeline");

    for (let vault of vaults) {
        writeStep(`adding for aave v3 - ${await vault.name()}`);
        const aToken = await aavePool.aTokens(vault.address);
        const tx1 = await registry.setVaultPipeline(
            aToken,
            aaveV3Pipeline.address
        );
        await tx1.wait();
    }

    // Yearn Single Token Pipeline

    writeStep("adding yearn single token pipeline");

    const yearnSingleTokenPipeline = await getContract(
        "YearnSingleTokenPipeline"
    );
    const yearnFactory = await getContract<YearnFactoryMock>(
        "YearnFactoryMock"
    );

    for (let token of tokens) {
        writeStep(`adding for yearn single token - ${await token.name()}`);
        const yearnVault = await yearnFactory.vaultFor(token.address);
        const tx1 = await registry.setVaultPipeline(
            yearnVault,
            yearnSingleTokenPipeline.address
        );
        await tx1.wait();
    }

    // Finish
    writeStartLine("Setup complete\n");
});
