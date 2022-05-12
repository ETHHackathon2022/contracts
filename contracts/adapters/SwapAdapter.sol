//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

contract SwapAdapter {
    enum DexType {
        None,
        Uniswap
    }

    struct UniswapParams {
        address router;
        address[] path;
        uint256 amountIn;
    }

    function _swap(DexType dexType, bytes memory encodedParams) internal {
        if (dexType == DexType.Uniswap) {
            UniswapParams memory params = abi.decode(
                encodedParams,
                UniswapParams
            );
            IERC20(params.path[0]).approve(dex, type(uint256).max);
            IUniswapV2Router02(params.router).swapExactTokensForTokens(
                params.amountIn,
                0,
                params.path,
                address(this),
                block.timestamp
            );
        } else {
            revert("Unsupported dex");
        }
    }

    function _multiSwap()
}
