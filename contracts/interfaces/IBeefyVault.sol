//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

interface IBeefyVault {
    function depositAll() external;

    function deposit(uint256 _amount) external;

    function withdrawAll() external;

    function withdraw(uint256 _shares) external;

    function want() external view returns (address);

    function balance() external view returns (uint256);
}
