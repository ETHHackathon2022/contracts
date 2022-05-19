// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "../interfaces/IRegistry.sol";

library Swaps {
    function swap(
        IRegistry registry,
        address from,
        address to,
        uint256 amountIn
    ) internal returns (uint256 amountOut) {
        IRegistry.SwapData memory swapData = registry.getSwapData(from, to);
        if (swapData.swapType == IRegistry.SwapType.UniswapV2) {
            // TODO: Get data and perform uniswap swap
        } else {
            // Perform default swap
            amountOut = defaultUniV2Swap(
                registry.defaultUniswapV2Router(),
                from,
                to,
                amountIn
            );
        }
    }

    function defaultUniV2Swap(
        address router,
        address from,
        address to,
        uint256 amountIn
    ) internal returns (uint256 amountOut) {
        // Try direct swap first
        address[] memory directPath = new address[](2);
        (directPath[0], directPath[1]) = (from, to);
        uint256 directAmountOut;
        try
            IUniswapV2Router02(router).getAmountsOut(amountIn, directPath)
        returns (uint256[] memory amountsOut) {
            directAmountOut = amountsOut[amountsOut.length - 1];
        } catch {
            // Do nothing
        }

        // Try swap using WETH
        uint256 wethAmountOut;
        address[] memory wethPath = new address[](3);
        address weth = IUniswapV2Router02(router).WETH();
        if (from != weth && to != weth) {
            (wethPath[0], wethPath[1], wethPath[2]) = (from, weth, to);
            try
                IUniswapV2Router02(router).getAmountsOut(amountIn, wethPath)
            returns (uint256[] memory amountsOut) {
                wethAmountOut = amountsOut[amountsOut.length - 1];
            } catch {
                // Do nothing
            }
        }

        // Perform swap
        require(
            directAmountOut > 0 || wethAmountOut > 0,
            "No swap route available"
        );
        amountOut = uniV2Swap(
            router,
            directAmountOut > wethAmountOut ? directPath : wethPath,
            amountIn
        );
    }

    function uniV2Swap(
        address router,
        address[] memory path,
        uint256 amountIn
    ) internal returns (uint256 amountOut) {
        IERC20(path[0]).approve(router, amountIn);
        uint256[] memory amounts = IUniswapV2Router02(router)
            .swapExactTokensForTokens(
                amountIn,
                0,
                path,
                address(this),
                block.timestamp
            );
        amountOut = amounts[amounts.length - 1];
        require(amountOut > 0, "Can't swap for zero");
    }
}
