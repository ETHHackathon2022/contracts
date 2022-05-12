//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "../interfaces/IBeefyVault.sol";

contract VaultAdapter {
    using SafeERC20 for IERC20;

    enum VaultType {
        None,
        Beefy
    }

    mapping(address => VaultType) public vaultTypes;

    function _withdraw(address vault, uint256 tokens)
        internal
        returns (uint256)
    {
        VaultType vaultType = vaultTypes[vault];
        if (vaultType == VaultType.Beefy) {
            uint256 balanceBefore = IERC20(IBeefyVault(vault).want()).balanceOf(
                address(this)
            );
            IBeefyVault(vault).withdraw(tokens);
            uint256 balanceAfter = IERC20(IBeefyVault(vault).want()).balanceOf(
                address(this)
            );
            return balanceAfter - balanceBefore;
        } else {
            revert("Unsupported vault");
        }
    }

    function _deposit(address vault, uint256 amount)
        internal
        returns (uint256)
    {
        VaultType vaultType = vaultTypes[vault];
        if (vaultType == VaultType.Beefy) {
            uint256 balanceBefore = IERC20(vault).balanceOf(address(this));
            IERC20(IBeefyVault(vault).want()).approve(vault, amount);
            IBeefyVault(vault).deposit(amount);
            uint256 balanceAfter = IERC20(vault).balanceOf(address(this));
            return balanceAfter - balanceBefore;
        } else {
            revert("Unsupported vault");
        }
    }
}
