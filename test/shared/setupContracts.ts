import { ethers } from "hardhat";
import { mineBlock } from "./utils";

const { AddressZero, MaxUint256 } = ethers.constants;
const { parseUnits, keccak256, concat, zeroPad, arrayify, toUtf8Bytes } =
    ethers.utils;

export async function setupContracts() {
    const [deployer] = await ethers.getSigners();

    // Deploy token mocks
    const TokenMockFactory = await ethers.getContractFactory("ERC20Mock");

    const usdc = await TokenMockFactory.deploy("USDC", "USDC", 6);
    const usdt = await TokenMockFactory.deploy("USDT", "USDT", 6);
    const dai = await TokenMockFactory.deploy("DAI", "DAI", 18);

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

    const usdcAmount = parseUnits("10000000", 6);
    const usdtAmount = parseUnits("10000000", 6);
    const daiAmount = parseUnits("10000000", 18);

    await usdc.mint(deployer.address, usdcAmount.mul(2));
    await usdt.mint(deployer.address, usdtAmount.mul(2));
    await dai.mint(deployer.address, daiAmount.mul(2));

    await usdc.approve(uniswapRouter.address, MaxUint256);
    await usdt.approve(uniswapRouter.address, MaxUint256);
    await dai.approve(uniswapRouter.address, MaxUint256);

    await uniswapFactory.createPair(usdc.address, usdt.address);
    await uniswapFactory.createPair(usdt.address, dai.address);
    await uniswapFactory.createPair(usdc.address, dai.address);

    await mineBlock();

    const block = await ethers.provider.getBlock(
        await ethers.provider.getBlockNumber()
    );
    await uniswapRouter.addLiquidity(
        usdc.address,
        usdt.address,
        usdcAmount,
        usdtAmount,
        0,
        0,
        deployer.address,
        block.timestamp + 100
    );
    await uniswapRouter.addLiquidity(
        usdt.address,
        dai.address,
        usdtAmount,
        daiAmount,
        0,
        0,
        deployer.address,
        block.timestamp + 100
    );
    await uniswapRouter.addLiquidity(
        usdc.address,
        dai.address,
        usdcAmount,
        daiAmount,
        0,
        0,
        deployer.address,
        block.timestamp + 100
    );

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

    // Deploy factory

    const IndexFactory = await ethers.getContractFactory("Index");
    const indexMaster = await IndexFactory.deploy();

    const FactoryFactory = await ethers.getContractFactory("Factory");
    const factory = await FactoryFactory.deploy(
        registry.address,
        indexMaster.address
    );

    // Return instances

    return { usdc, usdt, dai, registry, factory };
}
