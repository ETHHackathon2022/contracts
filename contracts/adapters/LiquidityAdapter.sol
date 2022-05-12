//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";

contract LiquidityAdapter {
    using SafeERC20 for IERC20;

    enum AssetType {
        None,
        Uniswap
    }

    struct AssetInfo {
        AssetType assetType;
        address router;
    }

    mapping(address => AssetInfo) public assetInfo;

    function _redeem(address asset, uint256 amount)
        internal
        returns (uint256[] memory amounts)
    {
        AssetInfo memory info = assetInfo[asset];
        if (info.assetType == AssetType.UniswapLP) {
            IERC20(asset).safeTransfer(asset, amount);
            (uint256 amount0, uint256 amount1) = IUniswapV2Pair(asset).burn(
                address(this)
            );
            amounts = new uint256[](2);
            amounts[0] = amount0;
            amounts[1] = amount1;
        } else {
            revert("Unsupported asset type");
        }
    }

    function _supply(address asset, uint256[] memory amounts)
        internal
        returns (uint256)
    {
        AssetInfo memory info = assetInfo[asset];
        if (info.assetType == AssetType.UniswapLP) {
            IERC20(IUniswapV2Pair(asset).token0()).safeTransfer(
                asset,
                amounts[0]
            );
            IERC20(IUniswapV2Pair(asset).token1()).safeTransfer(
                asset,
                amounts[1]
            );
            return IUniswapV2Pair(asset).mint(address(this));
        } else {
            revert("Unsupported asset type");
        }
    }
}
