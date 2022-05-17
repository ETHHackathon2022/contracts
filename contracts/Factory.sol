//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/IFactory.sol";
import "./interfaces/IIndex.sol";

contract Factory is IFactory {
    using SafeERC20 for IERC20;

    using Clones for address;

    address public registry;

    address public indexMaster;

    constructor(address registry_, address indexMaster_) {
        registry = registry_;
        indexMaster = indexMaster_;
    }

    function createIndex(
        string calldata name,
        string calldata symbol,
        IIndex.Component[] calldata components,
        uint256[] calldata weights,
        IERC20 tokenIn,
        uint256 amount
    ) external returns (address index) {
        index = indexMaster.clone();
        tokenIn.safeTransferFrom(msg.sender, index, amount);
        IIndex(index).initialize(
            name,
            symbol,
            msg.sender,
            components,
            weights,
            tokenIn,
            amount
        );
    }
}
