import { task } from "hardhat/config";

task("deploy:factory", "Deploy Factory contract")
    .addOptionalParam("registry", "Registry contract to use")
    .setAction(async function (
        { registry },
        { getNamedAccounts, deployments: { deploy }, ethers: { getContract } }
    ) {
        const { deployer } = await getNamedAccounts();

        const indexMaster = await deploy("IndexMaster", {
            contract: "VaultIndex",
            from: deployer,
            log: true,
        });

        if (!registry) {
            registry = (await getContract("Registry")).address;
        }

        return await deploy("Factory", {
            from: deployer,
            args: [registry, indexMaster.address],
            log: true,
        });
    });
