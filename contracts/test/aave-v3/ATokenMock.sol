// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ATokenMock is ERC20 {
    address public immutable UNDERLYING_ASSET_ADDRESS;

    address public immutable POOL;

    uint8 private _decimals;

    constructor(address underlying)
        ERC20(
            string(bytes.concat("a", bytes(ERC20(underlying).name()))),
            string(bytes.concat("a", bytes(ERC20(underlying).symbol())))
        )
    {
        UNDERLYING_ASSET_ADDRESS = underlying;
        POOL = msg.sender;
        _decimals = ERC20(underlying).decimals();
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external {
        _burn(from, amount);
    }
}
