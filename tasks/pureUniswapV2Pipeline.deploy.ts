import { task } from "hardhat/config";

task(
    "deploy:pureUniswapV2Pipeline",
    "Deploy PureUniswapV2Pipeline contract"
).setAction(async function (
    { _ },
    { getNamedAccounts, deployments: { deploy } }
) {
    const { deployer } = await getNamedAccounts();

    return await deploy("PureUniswapV2Pipeline", {
        from: deployer,
        args: [],
        log: true,
    });
});
