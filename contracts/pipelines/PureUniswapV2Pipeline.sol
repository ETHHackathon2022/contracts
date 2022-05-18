// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "../interfaces/IPipeline.sol";

contract PureUniswapV2Pipeline is IPipeline {
    string public constant PIPELINE_NAME = "PureUniswapV2Pipeline";

    bytes32 public constant ROUTER_SLOT =
        keccak256(abi.encodePacked(PIPELINE_NAME, "router"));

    // MUTATIVE FUNCTIONS

    function deposit(
        IRegistry registry,
        address vault,
        address tokenIn,
        uint256 amountIn
    ) external override returns (uint256 price) {
        uint256 amountOut;
        if (tokenIn != vault) {
            amountOut = _swap(registry, tokenIn, vault, amountIn);
        } else {
            amountOut = amountIn;
        }

        // TODO: Here should be actual price estimation using pricefeeds
        price = amountOut;
    }

    function withdraw(
        IRegistry registry,
        address vault,
        address tokenOut,
        uint256 shareNum,
        uint256 shareDenom
    ) external override returns (uint256 amountOut) {
        uint256 amountToWithdraw = (IERC20(vault).balanceOf(address(this)) *
            shareNum) / shareDenom;
        if (tokenOut != vault) {
            amountOut = _swap(registry, vault, tokenOut, amountToWithdraw);
        } else {
            amountOut = amountToWithdraw;
        }
    }

    // VIEW FUNCTIONS

    function getUnderlying(address vault)
        external
        pure
        override
        returns (address[] memory tokens)
    {
        tokens = new address[](1);
        tokens[0] = vault;
    }

    function getPrice(
        IRegistry,
        address vault,
        address account
    ) external view override returns (uint256) {
        // TODO: Here should be actual price estimation using pricefeeds
        uint256 balance = IERC20(vault).balanceOf(account);
        uint8 decimals = IERC20Metadata(vault).decimals();
        if (decimals < 18) {
            return balance * 10**(18 - decimals);
        } else {
            return balance / 10**(decimals - 18);
        }
    }

    // INTERNAL FUNCTIONS

    function _swap(
        IRegistry registry,
        address from,
        address to,
        uint256 amountIn
    ) private returns (uint256) {
        address router = abi.decode(
            registry.getPipelineData(ROUTER_SLOT),
            (address)
        );

        address[] memory path = new address[](2);
        (path[0], path[1]) = (from, to);

        IERC20(from).approve(router, type(uint256).max);
        IUniswapV2Router02(router).swapExactTokensForTokens(
            amountIn,
            0,
            path,
            address(this),
            block.timestamp
        );
        return 0;
    }
}
