import { BigNumberish } from "ethers";
import { ethers } from "hardhat";
import { Index } from "../../typechain";
import chalk from "chalk";

const { BigNumber } = ethers;
const { formatUnits } = ethers.utils;

export function formatUnitsWithPrecision(
    value: BigNumberish,
    decimals: number,
    precision: number
) {
    const cutter = BigNumber.from(10).pow(decimals - precision);
    const cutPart = BigNumber.from(value).mod(cutter);

    let roundedValue = BigNumber.from(value).sub(cutPart);
    if (cutPart >= cutter.div(2)) {
        roundedValue = roundedValue.add(cutter);
    }

    return formatUnits(roundedValue, decimals);
}

export function displayBlock(text: string, length: number, color: string) {
    let output;
    if (text.length < length) {
        const addon = Array(length - text.length)
            .map(() => "")
            .join(" ");
        output = " " + text + addon;
    } else {
        output = text.slice(0, length);
    }

    process.stdout.write(chalk.bgHex(color).black(output));
}

export async function displayIndex(index: Index) {
    const colors = [
        "#DDED7A", // Light yellow
        "#82DBD1", // Cyan
        "#A757B0", // Purple,
        "#3A7C51", // Dark green
    ];

    let [prices, totalPrice] = await index.getComponentPrices();

    const header =
        (await index.name()) +
        " (" +
        (await index.symbol()) +
        ") | " +
        "Total price: " +
        formatUnitsWithPrecision(totalPrice, 18, 2) +
        " USD";
    console.log(chalk.bold(header));

    if (totalPrice.eq(0)) {
        console.error("Can't display empty vault");
        return;
    }

    let totalLength = 100;

    for (let i = 0; i < prices.length; i++) {
        const vault = await index.components(i);

        const token = await ethers.getContractAt("ERC20Mock", vault);
        const text =
            (await token.name()) +
            ": " +
            formatUnitsWithPrecision(
                await token.balanceOf(index.address),
                await token.decimals(),
                2
            );
        const length = BigNumber.from(totalLength)
            .mul(prices[i])
            .div(totalPrice)
            .toNumber();
        totalPrice = totalPrice.sub(prices[i]);
        totalLength -= length;
        displayBlock(text, length, colors[i]);
    }
    console.log("");
}
