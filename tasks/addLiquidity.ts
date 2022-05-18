import { parseUnits } from "ethers/lib/utils";
import { task } from "hardhat/config";
import { ERC20Mock, UniswapV2Router02 } from "../typechain";

const defaultParams = {
    router: "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D",
};

task("addLiquidity", "Add liquidity to uniswap V2 pool")
    .addParam("tokenA", "First token of the pair")
    .addParam("tokenB", "Second token of the pair")
    .addParam("amountA", "Amount of the first token, as units (ether)")
    .addParam("amountB", "Amount of the second token, as units (ether)")
    .addOptionalParam("router", "Uniswap router to use", defaultParams.router)
    .setAction(async function (
        { tokenA, tokenB, amountA, amountB, router },
        {
            getNamedAccounts,
            ethers: {
                getContractAt,
                constants: { MaxUint256 },
                provider: { getBlock, getBlockNumber },
            },
        }
    ) {
        const { deployer } = await getNamedAccounts();

        const tokenAContract = await getContractAt<ERC20Mock>(
            "ERC20Mock",
            tokenA
        );
        const tokenBContract = await getContractAt<ERC20Mock>(
            "ERC20Mock",
            tokenB
        );

        const weiA = parseUnits(amountA, await tokenAContract.decimals());
        const weiB = parseUnits(amountB, await tokenBContract.decimals());

        let tx = await tokenAContract.mint(deployer, weiA);
        await tx.wait();
        tx = await tokenBContract.mint(deployer, weiB);
        await tx.wait();

        const routerContract = await getContractAt(
            "IUniswapV2Router02",
            router
        );

        tx = await tokenAContract.approve(router, MaxUint256);
        await tx.wait();
        tx = await tokenBContract.approve(router, MaxUint256);
        await tx.wait();

        const block = await getBlock(getBlockNumber());
        tx = await routerContract.addLiquidity(
            tokenA,
            tokenB,
            weiA,
            weiB,
            0,
            0,
            deployer,
            block.timestamp + 100
        );
    });
