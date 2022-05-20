import { task } from "hardhat/config";

task("deploy:yearnFactoryMock", "Deploy Yearn factory mock contract").setAction(
    async function ({ _ }, { getNamedAccounts, deployments: { deploy } }) {
        const { deployer } = await getNamedAccounts();
        return await deploy("YearnFactoryMock", {
            from: deployer,
            args: [],
            log: true,
        });
    }
);
