import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const deployFunction: DeployFunction = async function ({
    run,
}: HardhatRuntimeEnvironment) {
    await run("deploy:pipeline", { pipeline: "PurePipeline" });

    await run("deploy:pipeline", { pipeline: "AaveV3Pipeline" });

    await run("deploy:pipeline", { pipeline: "YearnSingleTokenPipeline" });
};

export default deployFunction;

deployFunction.tags = ["Pipelines", "Production"];
