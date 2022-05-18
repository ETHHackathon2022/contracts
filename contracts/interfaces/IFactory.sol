// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.13;

interface IFactory {
    function registry() external view returns (address);
}
