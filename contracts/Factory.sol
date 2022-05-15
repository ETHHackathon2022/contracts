//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "./interfaces/IFactory.sol";

contract Factory is IFactory {
    address public registry;

    address public indexMaster;

    constructor(address registry_, address indexMaster_) {
        registry = registry_;
        indexMaster = indexMaster_;
    }
}
