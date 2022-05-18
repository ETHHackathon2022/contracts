// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.13;

interface IRegistry {
    function getVaultPipeline(address vault) external view returns (address);

    function getPipelineData(bytes32 slot) external view returns (bytes memory);
}
