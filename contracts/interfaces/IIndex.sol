//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IIndex {
    struct Component {
        address vault;
    }

    function initialize(
        string calldata name_,
        string calldata symbol_,
        address owner_,
        Component[] memory components_,
        uint256[] memory weights_,
        IERC20 tokenIn,
        uint256 amount
    ) external;
}
