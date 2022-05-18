// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IRegistry.sol";

contract Registry is IRegistry, Ownable {
    mapping(address => address) public getVaultPipeline;

    mapping(bytes32 => bytes) public getPipelineData;

    // RESTRICTED FUNCTIONS

    function setVaultPipeline(address vault, address pipeline)
        external
        onlyOwner
    {
        getVaultPipeline[vault] = pipeline;
    }

    function setPipelineData(bytes32 slot, bytes memory data)
        external
        onlyOwner
    {
        getPipelineData[slot] = data;
    }
}
