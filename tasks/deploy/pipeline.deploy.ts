import { task } from "hardhat/config";

task("deploy:pipeline", "Deploy pipeline contract")
    .addParam("pipeline", "Pipeline name to deploy")
    .setAction(async function (
        { pipeline },
        { getNamedAccounts, deployments: { deploy } }
    ) {
        const { deployer } = await getNamedAccounts();

        return await deploy(pipeline, {
            from: deployer,
            args: [],
            log: true,
        });
    });
