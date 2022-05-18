import * as dotenv from "dotenv";

import { HardhatUserConfig, task } from "hardhat/config";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "@nomiclabs/hardhat-ethers";
import "@typechain/hardhat";
import "hardhat-gas-reporter";
import "hardhat-spdx-license-identifier";
import "solidity-coverage";
import "@openzeppelin/hardhat-upgrades";
import "hardhat-deploy";
import "hardhat-dependency-compiler";
import "./tasks";

dotenv.config();

task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
    const accounts = await hre.ethers.getSigners();

    for (const account of accounts) {
        console.log(account.address);
    }
});

const ethereumConfig = {
    url: process.env.RPC_URL || "",
    accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
};

const config: HardhatUserConfig = {
    solidity: {
        compilers: [
            {
                version: "0.8.13",
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 200,
                    },
                },
            },
            {
                version: "0.6.6",
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 200,
                    },
                },
            },
            {
                version: "0.5.16",
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 200,
                    },
                },
            },
        ],
    },
    namedAccounts: {
        deployer: {
            default: 0,
        },
    },
    networks: {
        hardhat: {
            forking: {
                url: process.env.FORKING_RPC_URL!,
                blockNumber: 14791509,
            },
        },
        mainnet: ethereumConfig,
        ropsten: ethereumConfig,
        rinkeby: ethereumConfig,
        kovan: ethereumConfig,
        BSCTest: {
            url: "https://data-seed-prebsc-1-s1.binance.org:8545/",
            accounts:
                process.env.PRIVATE_KEY !== undefined
                    ? [process.env.PRIVATE_KEY]
                    : [],
        },
        BSC: {
            url: "https://bsc-dataseed.binance.org/",
            accounts:
                process.env.PRIVATE_KEY !== undefined
                    ? [process.env.PRIVATE_KEY]
                    : [],
        },
        mumbai: ethereumConfig,
        polygon: ethereumConfig,
    },
    gasReporter: {
        enabled: process.env.REPORT_GAS !== undefined,
        currency: "USD",
    },
    etherscan: {
        apiKey: process.env.ETHERSCAN_API_KEY,
    },
    spdxLicenseIdentifier: {
        overwrite: true,
        runOnCompile: true,
    },
    verify: {
        etherscan: {
            apiKey: process.env.ETHERSCAN_API_KEY,
        },
    },
    external: {
        contracts: [
            {
                artifacts: "@uniswap/v2-periphery/build",
            },
        ],
    },
    dependencyCompiler: {
        paths: [
            "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol",
        ],
    },
};

export default config;
