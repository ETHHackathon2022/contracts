// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IRegistry.sol";

contract Registry is IRegistry, Ownable {
    mapping(address => address) public getVaultPipeline;

    mapping(bytes32 => bytes) public getPipelineData;

    address public defaultUniswapV2Router;

    mapping(address => mapping(address => SwapData)) private _swapData;

    // RESTRICTED FUNCTIONS

    function setVaultPipeline(address vault, address pipeline)
        external
        onlyOwner
    {
        getVaultPipeline[vault] = pipeline;
    }

    function setPipelineData(bytes32 slot, bytes memory data)
        external
        onlyOwner
    {
        getPipelineData[slot] = data;
    }

    function setDefaultUniswapV2Router(address router) external onlyOwner {
        defaultUniswapV2Router = router;
    }

    // VIEW FUNCTIONS

    function getSwapData(address from, address to)
        external
        view
        returns (SwapData memory)
    {
        if (_swapData[from][to].swapType != SwapType.None) {
            return _swapData[from][to];
        } else {
            return _swapData[to][from];
        }
    }
}
