// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "./YearnVaultMock.sol";

contract YearnFactoryMock {
    mapping(address => address) public vaultFor;

    function deployVault(address token) external {
        vaultFor[token] = address(new YearnVaultMock(token));
    }
}
