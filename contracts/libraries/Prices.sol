// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "../interfaces/IRegistry.sol";

library Prices {
    using SafeCast for int256;

    uint256 internal constant ONE = 10**8;

    function getPrice(IRegistry registry, address token)
        internal
        view
        returns (uint256)
    {
        AggregatorV3Interface feed = AggregatorV3Interface(
            registry.getPriceFeed(token)
        );
        if (address(feed) != address(0)) {
            (, int256 price, , , ) = feed.latestRoundData();
            if (price < 0) {
                return 0;
            }
            return price.toUint256();
        } else {
            // For now assume all tokens cost 1 USD (i.e. stablecoins)
            return ONE;
        }
    }

    function toUSD(
        IRegistry registry,
        address token,
        uint256 amount
    ) internal view returns (uint256) {
        return
            (amount * getPrice(registry, token)) /
            10**IERC20Metadata(token).decimals();
    }
}
