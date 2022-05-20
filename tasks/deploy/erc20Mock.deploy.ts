import { task } from "hardhat/config";

task("deploy:erc20Mock", "Deploy ERC20Mock contract")
    .addParam("name", "The ERC20 token name")
    .addParam("symbol", "The ERC20 token symbol")
    .addOptionalParam("decimals", "The ERC20 token decimals", "18")
    .setAction(async function (
        { name, symbol, decimals },
        { getNamedAccounts, deployments: { deploy } }
    ) {
        const { deployer } = await getNamedAccounts();

        return await deploy(name, {
            contract: "ERC20Mock",
            from: deployer,
            args: [name, symbol, decimals],
            log: true,
        });
    });
