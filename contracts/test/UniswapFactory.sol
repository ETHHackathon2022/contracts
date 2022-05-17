//SPDX-License-Identifier: Unlicense
pragma solidity 0.5.16;

import "@uniswap/v2-core/contracts/UniswapV2Factory.sol";

contract UniswapFactory is UniswapV2Factory {
    constructor(address _feeToSetter) public UniswapV2Factory(_feeToSetter) {}
}
