import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { YearnFactoryMock } from "../typechain-types/YearnFactoryMock";

const deployFunction: DeployFunction = async function ({
    run,
    ethers: { getContract },
}: HardhatRuntimeEnvironment) {
    await run("deploy:yearnFactoryMock");

    const yearnFactory = await getContract<YearnFactoryMock>(
        "YearnFactoryMock"
    );

    const tokens = [
        await getContract("USDC"),
        await getContract("USDT"),
        await getContract("DAI"),
        await getContract("BUSD"),
    ];

    for (let token of tokens) {
        const tx = await yearnFactory.deployVault(token.address);
        await tx.wait();
    }
};

export default deployFunction;

deployFunction.dependencies = ["Tokens"];

deployFunction.tags = ["YearnMock"];
