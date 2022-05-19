import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const deployFunction: DeployFunction = async function ({
    run,
}: HardhatRuntimeEnvironment) {
    await run("deploy:factory", {});
};

export default deployFunction;

deployFunction.dependencies = ["Registry"];

deployFunction.tags = ["Factory", "Production"];
