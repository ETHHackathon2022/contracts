import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { ethers } from "hardhat";
import { ERC20Mock, UniswapRouter } from "../../typechain";
import { mineBlock } from "./utils";

const { AddressZero, MaxUint256 } = ethers.constants;
const { parseUnits, keccak256, concat, zeroPad, arrayify, toUtf8Bytes } =
    ethers.utils;

async function addLiquidityUSD(
    from: SignerWithAddress,
    router: UniswapRouter,
    tokenA: ERC20Mock,
    tokenB: ERC20Mock,
    amount = "10000000"
) {
    const amountA = parseUnits(amount, await tokenA.decimals());
    const amountB = parseUnits(amount, await tokenB.decimals());

    await tokenA.mint(from.address, amountA);
    await tokenB.mint(from.address, amountB);
    await tokenA.approve(router.address, MaxUint256);
    await tokenB.approve(router.address, MaxUint256);

    const block = await ethers.provider.getBlock(
        await ethers.provider.getBlockNumber()
    );
    await router.addLiquidity(
        tokenA.address,
        tokenB.address,
        amountA,
        amountB,
        0,
        0,
        from.address,
        block.timestamp + 100
    );
}

export async function setupContracts() {
    const [deployer] = await ethers.getSigners();

    // Deploy token mocks
    const TokenMockFactory = await ethers.getContractFactory("ERC20Mock");

    const usdc = await TokenMockFactory.deploy("USDC", "USDC", 6);
    const usdt = await TokenMockFactory.deploy("USDT", "USDT", 6);
    const dai = await TokenMockFactory.deploy("DAI", "DAI", 18);
    const busd = await TokenMockFactory.deploy("BUSD", "BUSD", 18);

    // Deploy uniswap

    const UniswapFactoryFactory = await ethers.getContractFactory(
        "UniswapFactory"
    );
    /*const uniswapFactory = await UniswapFactoryFactory.deploy(deployer.address);*/
    const uniswapFactory = await UniswapFactoryFactory.attach(
        "0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f"
    );

    const UniswapRouterFactory = await ethers.getContractFactory(
        "UniswapRouter"
    );
    /*const uniswapRouter = await UniswapRouterFactory.deploy(
        uniswapFactory.address,
        deployer.address
    );*/
    const uniswapRouter = await UniswapRouterFactory.attach(
        "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D"
    );

    // Add uniswap liquidity

    const tokens = [usdc, usdt, dai, busd];
    for (let i = 0; i < tokens.length; i++) {
        for (let j = i + 1; j < tokens.length; j++) {
            await addLiquidityUSD(
                deployer,
                uniswapRouter,
                tokens[i],
                tokens[j]
            );
        }
    }

    // Deploy registry and pipelines

    const RegistryFactory = await ethers.getContractFactory("Registry");
    const registry = await RegistryFactory.deploy();

    const PureUniswapV2PipelineFactory = await ethers.getContractFactory(
        "PureUniswapV2Pipeline"
    );
    const pureUniswapV2Pipeline = await PureUniswapV2PipelineFactory.deploy();

    const slot = keccak256(
        concat([
            toUtf8Bytes(await pureUniswapV2Pipeline.PIPELINE_NAME()),
            toUtf8Bytes("router"),
        ])
    );
    const data = ethers.utils.defaultAbiCoder.encode(
        ["address"],
        [uniswapRouter.address]
    );
    await registry.setPipelineData(slot, data);

    await registry.setVaultPipeline(
        usdc.address,
        pureUniswapV2Pipeline.address
    );
    await registry.setVaultPipeline(
        usdt.address,
        pureUniswapV2Pipeline.address
    );
    await registry.setVaultPipeline(dai.address, pureUniswapV2Pipeline.address);
    await registry.setVaultPipeline(
        busd.address,
        pureUniswapV2Pipeline.address
    );

    // Deploy factory

    const IndexFactory = await ethers.getContractFactory("Index");
    const indexMaster = await IndexFactory.deploy();

    const FactoryFactory = await ethers.getContractFactory("Factory");
    const factory = await FactoryFactory.deploy(
        registry.address,
        indexMaster.address
    );

    // Return instances

    return {
        usdc,
        usdt,
        dai,
        busd,
        uniswapRouter,
        uniswapFactory,
        registry,
        factory,
    };
}
