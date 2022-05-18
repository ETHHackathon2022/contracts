import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const deployFunction: DeployFunction = async function ({
    run,
}: HardhatRuntimeEnvironment) {
    await run("deploy:pureUniswapV2Pipeline");
};

export default deployFunction;

deployFunction.tags = ["Pipelines"];
