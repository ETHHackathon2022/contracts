import { task } from "hardhat/config";

task("deploy:aaveV3Pipeline", "Deploy AaveV3Pipeline contract").setAction(
    async function ({ _ }, { getNamedAccounts, deployments: { deploy } }) {
        const { deployer } = await getNamedAccounts();

        return await deploy("AaveV3Pipeline", {
            from: deployer,
            args: [],
            log: true,
        });
    }
);
