// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IVaultIndex {
    struct Component {
        address vault;
        uint256 targetWeight;
    }

    function initialize(
        string calldata name_,
        string calldata symbol_,
        address owner_,
        Component[] memory components_
    ) external;
}
