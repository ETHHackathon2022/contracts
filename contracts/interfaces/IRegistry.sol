// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface IRegistry {
    function getVaultPipeline(address vault) external view returns (address);

    function getPipelineData(bytes32 slot) external view returns (bytes memory);

    function isTokenWhitelisted(address token) external view returns (bool);

    enum SwapType {
        None,
        UniswapV2
    }

    struct SwapData {
        SwapType swapType;
        bytes data;
    }

    function getSwapData(address from, address to)
        external
        view
        returns (SwapData memory);

    function defaultUniswapV2Router() external view returns (address);
}
