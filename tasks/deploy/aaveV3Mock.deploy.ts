import { task } from "hardhat/config";

task("deploy:aaveV3Mock", "Deploy Aave V3 mock contract").setAction(
    async function ({ _ }, { getNamedAccounts, deployments: { deploy } }) {
        const { deployer } = await getNamedAccounts();
        return await deploy("AaveV3Pool", {
            contract: "PoolMock",
            from: deployer,
            args: [],
            log: true,
        });
    }
);
