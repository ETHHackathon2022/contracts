import { task } from "hardhat/config";

task("deploy:registry", "Deploy Registry contract").setAction(async function (
    { _ },
    { getNamedAccounts, deployments: { deploy } }
) {
    const { deployer } = await getNamedAccounts();

    return await deploy("Registry", {
        from: deployer,
        args: [],
        log: true,
    });
});
