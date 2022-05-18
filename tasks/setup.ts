import { task } from "hardhat/config";
import chalk from "chalk";

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
    {
        run,
        ethers: {
            getContract,
            utils: { keccak256, concat, toUtf8Bytes, defaultAbiCoder },
        },
    }
) {
    writeStartLine("Starting set up...");

    // Add liquidity to all default pairs
    writeStep("adding liquidity");

    const tokens = [
        await getContract("USDC"),
        await getContract("USDT"),
        await getContract("DAI"),
        await getContract("BUSD"),
    ];
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

    // Set pipelines
    writeStep("adding pipelines");

    // Pure Uniswap V2 Pipeline

    writeStep("setting pure uniswapv2 pipeline data");

    const pureUniswapV2Pipeline = await getContract("PureUniswapV2Pipeline");
    const registry = await getContract("Registry");
    const uniswapRouter = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";

    const slot = keccak256(
        concat([
            toUtf8Bytes(await pureUniswapV2Pipeline.PIPELINE_NAME()),
            toUtf8Bytes("router"),
        ])
    );
    const data = defaultAbiCoder.encode(["address"], [uniswapRouter]);
    const tx = await registry.setPipelineData(slot, data);
    await tx.wait();

    writeStep("adding pure uniswap2 pipeline");

    const vaults = tokens;
    for (let vault of vaults) {
        writeStep(`adding for vault ${await vault.name()}`);
        const tx1 = await registry.setVaultPipeline(
            vault.address,
            pureUniswapV2Pipeline.address
        );
        await tx1.wait();
    }

    // Finish
    writeStartLine("Setup complete\n");
});
