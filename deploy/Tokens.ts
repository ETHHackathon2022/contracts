import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const deployFunction: DeployFunction = async function ({
    run,
}: HardhatRuntimeEnvironment) {
    await run("deploy:erc20Mock", {
        name: "USDT",
        symbol: "USDT",
        decimals: "6",
    });
    await run("deploy:erc20Mock", {
        name: "USDC",
        symbol: "USDC",
        decimals: "6",
    });
    await run("deploy:erc20Mock", {
        name: "DAI",
        symbol: "DAI",
        decimals: "18",
    });
    await run("deploy:erc20Mock", {
        name: "BUSD",
        symbol: "BUSD",
        decimals: "18",
    });
};

export default deployFunction;

deployFunction.tags = ["Tokens", "Production"];
