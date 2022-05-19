// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "./IRegistry.sol";

interface IPipeline {
    // MUTATIVE FUNCTIONS

    function deposit(
        IRegistry registry,
        address vault,
        address tokenIn,
        uint256 amountIn
    ) external returns (uint256 price);

    function withdraw(
        IRegistry registry,
        address vault,
        address tokenOut,
        uint256 shareNum,
        uint256 shareDenom
    ) external returns (uint256 amountOut);

    // VIEW FUNCTIONS

    function getUnderlying(address vault)
        external
        view
        returns (address[] memory tokens);

    function getPrice(
        IRegistry registry,
        address vault,
        address account
    ) external view returns (uint256 price);
}
