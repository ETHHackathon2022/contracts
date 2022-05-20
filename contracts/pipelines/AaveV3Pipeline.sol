// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "../libraries/Swaps.sol";
import "../libraries/Prices.sol";
import "../interfaces/IPipeline.sol";
import "../interfaces/aave-v3/IAToken.sol";
import "../interfaces/aave-v3/IPool.sol";

contract AaveV3Pipeline is IPipeline {
    using Swaps for IRegistry;
    using Prices for IRegistry;

    string public constant PIPELINE_NAME = "AaveV3Pipeline";

    // MUTATIVE FUNCTIONS

    function deposit(
        IRegistry registry,
        address vault,
        address tokenIn,
        uint256 amountIn
    ) external override returns (uint256 price) {
        address underlying = IAToken(vault).UNDERLYING_ASSET_ADDRESS();
        address pool = IAToken(vault).POOL();

        uint256 supplyAmount;
        if (tokenIn != underlying) {
            supplyAmount = registry.swap(tokenIn, underlying, amountIn);
        } else {
            supplyAmount = amountIn;
        }

        IERC20(underlying).approve(pool, supplyAmount);
        IPool(pool).supply(underlying, supplyAmount, address(this), 0);

        price = registry.toUSD(underlying, supplyAmount);
    }

    function withdraw(
        IRegistry registry,
        address vault,
        address tokenOut,
        uint256 shareNum,
        uint256 shareDenom
    ) external override returns (uint256 amountOut) {
        address underlying = IAToken(vault).UNDERLYING_ASSET_ADDRESS();
        address pool = IAToken(vault).POOL();

        uint256 withdrawAmount = (IERC20(vault).balanceOf(address(this)) *
            shareNum) / shareDenom;
        withdrawAmount = IPool(pool).withdraw(
            underlying,
            withdrawAmount,
            address(this)
        );

        if (tokenOut != underlying) {
            amountOut = registry.swap(underlying, tokenOut, withdrawAmount);
        } else {
            amountOut = withdrawAmount;
        }
    }

    // VIEW FUNCTIONS

    function getUnderlying(address vault)
        external
        view
        override
        returns (address[] memory tokens)
    {
        tokens = new address[](1);
        tokens[0] = IAToken(vault).UNDERLYING_ASSET_ADDRESS();
    }

    function getPrice(
        IRegistry registry,
        address vault,
        address account
    ) external view override returns (uint256) {
        uint256 balance = IAToken(vault).balanceOf(account);
        return
            registry.toUSD(IAToken(vault).UNDERLYING_ASSET_ADDRESS(), balance);
    }
}
