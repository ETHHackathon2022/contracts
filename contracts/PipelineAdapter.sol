// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IRegistry.sol";
import "./interfaces/IPipeline.sol";

contract PipelineAdapter {
    using Address for address;

    IRegistry public registry;

    function _deposit(
        address vault,
        IERC20 tokenIn,
        uint256 amountIn
    ) internal returns (uint256 price) {
        address pipeline = registry.getVaultPipeline(vault);
        bytes memory returnData = pipeline.functionDelegateCall(
            abi.encodeWithSelector(
                IPipeline.deposit.selector,
                registry,
                vault,
                address(tokenIn),
                amountIn
            )
        );
        return abi.decode(returnData, (uint256));
    }

    function _withdraw(
        address vault,
        IERC20 tokenOut,
        uint256 shareNum,
        uint256 shareDenom
    ) internal returns (uint256 amountOut) {
        address pipeline = registry.getVaultPipeline(vault);
        bytes memory returnData = pipeline.functionDelegateCall(
            abi.encodeWithSelector(
                IPipeline.withdraw.selector,
                registry,
                vault,
                address(tokenOut),
                shareNum,
                shareDenom
            )
        );
        return abi.decode(returnData, (uint256));
    }

    function _getUnderlying(address vault)
        internal
        view
        returns (address[] memory)
    {
        address pipeline = registry.getVaultPipeline(vault);
        return IPipeline(pipeline).getUnderlying(vault);
    }

    function _getPrice(address vault) internal view returns (uint256) {
        address pipeline = registry.getVaultPipeline(vault);
        return IPipeline(pipeline).getPrice(registry, vault, address(this));
    }
}
