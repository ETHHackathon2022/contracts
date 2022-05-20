// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

contract YearnVaultMock is ERC20 {
    using SafeERC20 for IERC20;

    IERC20 public token;

    uint8 private _decimals;

    constructor(address token_)
        ERC20(
            string(bytes.concat("y", bytes(IERC20Metadata(token_).name()))),
            string(bytes.concat("y", bytes(IERC20Metadata(token_).symbol())))
        )
    {
        token = IERC20(token_);
        _decimals = IERC20Metadata(token_).decimals();
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    function deposit(uint256 _amount) external returns (uint256) {
        token.safeTransferFrom(msg.sender, address(this), _amount);
        _mint(msg.sender, _amount);
        return _amount;
    }

    function withdraw(uint256 maxShares) external returns (uint256) {
        _burn(msg.sender, maxShares);
        token.safeTransfer(msg.sender, maxShares);
        return maxShares;
    }

    function totalAssets() external view returns (uint256) {
        return token.balanceOf(address(this));
    }
}
