import { task } from "hardhat/config";

task("deploy:uniswapV2", "deploy uniswap v2 factory, router")
    .addOptionalParam("factoryName", "factory name", "UniswapV2Factory")
    .addOptionalParam("routerName", "router name", "UniswapV2Router")
    .setAction(async function (
        { factoryName, routerName },
        { getNamedAccounts, deployments: { deploy, getArtifact } }
    ) {
        const { deployer } = await getNamedAccounts();
        const UniswapV2FactoryArtifact = await getArtifact("UniswapV2Factory");
        const UniswapV2Router02Artifact = await getArtifact(
            "UniswapV2Router02"
        );

        const UniswapV2Factory = await deploy(factoryName, {
            contract: {
                abi: UniswapV2FactoryArtifact.abi,
                bytecode: UniswapV2FactoryArtifact.bytecode,
            },
            from: deployer,
            args: [deployer],
            log: true,
        });

        const UniswapV2Router = await deploy(routerName, {
            contract: {
                abi: UniswapV2Router02Artifact.abi,
                bytecode: UniswapV2Router02Artifact.bytecode,
            },
            from: deployer,
            args: [UniswapV2Factory.address, deployer],
            log: true,
        });
        return [UniswapV2Factory, UniswapV2Router];
    });
