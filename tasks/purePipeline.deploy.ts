import { task } from "hardhat/config";

task("deploy:purePipeline", "Deploy PurePipeline contract").setAction(
    async function ({ _ }, { getNamedAccounts, deployments: { deploy } }) {
        const { deployer } = await getNamedAccounts();

        return await deploy("PurePipeline", {
            from: deployer,
            args: [],
            log: true,
        });
    }
);
