// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "../libraries/Swaps.sol";
import "../libraries/Prices.sol";
import "../interfaces/IPipeline.sol";
import "../interfaces/yearn/IYearnVault.sol";

contract YearnSingleTokenPipeline is IPipeline {
    using Swaps for IRegistry;
    using Prices for IRegistry;

    string public constant PIPELINE_NAME = "YearnSingleTokenPipline";

    // MUTATIVE FUNCTIONS

    function deposit(
        IRegistry registry,
        address vault,
        address tokenIn,
        uint256 amountIn
    ) external override returns (uint256 price) {
        address underlying = IYearnVault(vault).token();

        uint256 supplyAmount;
        if (tokenIn != underlying) {
            supplyAmount = registry.swap(tokenIn, underlying, amountIn);
        } else {
            supplyAmount = amountIn;
        }

        IERC20(underlying).approve(vault, supplyAmount);
        IYearnVault(vault).deposit(supplyAmount);

        price = registry.toUSD(underlying, supplyAmount);
    }

    function withdraw(
        IRegistry registry,
        address vault,
        address tokenOut,
        uint256 shareNum,
        uint256 shareDenom
    ) external override returns (uint256 amountOut) {
        address underlying = IYearnVault(vault).token();

        uint256 withdrawAmount = (IERC20(vault).balanceOf(address(this)) *
            shareNum) / shareDenom;
        withdrawAmount = IYearnVault(vault).withdraw(withdrawAmount);

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
        tokens[0] = IYearnVault(vault).token();
    }

    function getPrice(
        IRegistry registry,
        address vault,
        address account
    ) external view override returns (uint256) {
        uint256 totalAssets = IYearnVault(vault).totalAssets();
        uint256 vaultBalance = IYearnVault(vault).balanceOf(account);
        uint256 vaultTotalSupply = IYearnVault(vault).totalSupply();
        if (vaultTotalSupply == 0) {
            return 0;
        }
        uint256 balance = ((totalAssets * vaultBalance) / vaultTotalSupply);
        return registry.toUSD(IYearnVault(vault).token(), balance);
    }
}
