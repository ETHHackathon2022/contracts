// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./ATokenMock.sol";

contract PoolMock {
    using SafeERC20 for IERC20;

    mapping(address => address) public aTokens;

    function supply(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16
    ) external {
        IERC20(asset).safeTransferFrom(msg.sender, address(this), amount);
        ATokenMock(aTokens[asset]).mint(onBehalfOf, amount);
    }

    function withdraw(
        address asset,
        uint256 amount,
        address to
    ) external returns (uint256) {
        ATokenMock(aTokens[asset]).burn(msg.sender, amount);
        IERC20(asset).safeTransfer(to, amount);
        return amount;
    }

    function addAsset(address asset) external {
        require(aTokens[asset] == address(0), "Already added");
        aTokens[asset] = address(new ATokenMock(asset));
    }
}
