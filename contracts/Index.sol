//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./PipelineAdapter.sol";
import "./interfaces/IRegistry.sol";
import "./interfaces/IFactory.sol";

contract Index is PipelineAdapter, ERC20, Ownable {
    using SafeERC20 for IERC20;

    struct Component {
        address vault;
    }

    Component[] public components;

    // CONSTRUCTOR

    constructor(
        string memory name_,
        string memory symbol_,
        address owner_,
        Component[] memory components_
    ) ERC20(name_, symbol_) {
        registry = IRegistry(IFactory(msg.sender).registry());

        transferOwnership(owner_);

        for (uint256 i = 0; i < components_.length; i++) {
            components.push(components_[i]);
        }
    }

    // PUBLIC FUNCTIONS

    function deposit(IERC20 tokenIn, uint256 amount) external {
        // Transfer token to address
        tokenIn.safeTransferFrom(msg.sender, address(this), amount);

        // Get component prices and total prices
        (uint256[] memory prices, uint256 totalPrice) = getComponentPrices();
        uint256 boughtPrice;

        // Deposit each component according to it's current share and sum bought prices
        for (uint256 i = 0; i < components.length; i++) {
            boughtPrice += _deposit(
                components[i].vault,
                tokenIn,
                (amount * prices[i]) / totalPrice
            );
        }

        // Mint i-tokens according to relating of bought price to current total price
        _mint(msg.sender, (totalSupply() * boughtPrice) / totalPrice);
    }

    function withdraw(IERC20 tokenOut, uint256 tokens)
        external
        returns (uint256 amountOut)
    {
        // Burn i-tokens from sender address
        uint256 supply = totalSupply();
        _burn(msg.sender, tokens);

        // Withdraw share in each component
        for (uint256 i = 0; i < components.length; i++) {
            amountOut += _withdraw(
                components[i].vault,
                tokenOut,
                tokens,
                supply
            );
        }

        // Transfer obtained funds to sender
        tokenOut.safeTransfer(msg.sender, amountOut);
    }

    // RESTRICTED PUBLIC FUNCTIONS

    function addComponentAndRebalance(
        Component memory component,
        uint256 orderDecrease,
        uint256 shareNum,
        uint256 shareDenom
    ) external onlyOwner {
        // Add component to list
        components.push(component);

        // Rebalance to new component
        rebalanceComponent(
            orderDecrease,
            components.length - 1,
            shareNum,
            shareDenom
        );
    }

    function rebalanceComponent(
        uint256 orderDecrease,
        uint256 orderIncrease,
        uint256 shareNum,
        uint256 shareDenom
    ) public onlyOwner returns (uint256 price) {
        // Get intermediate token
        IERC20 through = IERC20(getComponentUnderlying(orderIncrease)[0]);

        // Withdraw first component to this token
        uint256 sellPrice = _withdraw(
            components[orderDecrease].vault,
            through,
            shareNum,
            shareDenom
        );

        // Deposit to second components with this token
        price = _deposit(components[orderIncrease].vault, through, sellPrice);
    }

    function removeComponent(uint256 order) external onlyOwner {
        // Get component prices and total price
        (uint256[] memory prices, uint256 totalPrice) = getComponentPrices();
        totalPrice -= prices[order];

        // Deposit to each other component using shares of removed component
        for (uint256 i = 0; i < prices.length; i++) {
            if (i != order) {
                rebalanceComponent(order, i, prices[i], totalPrice);
                totalPrice -= prices[i];
            }
        }

        // Remove component from list
        components[order] = components[components.length - 1];
        components.pop();
    }

    // PUBLIC VIEW FUNCTIONS

    function getComponentPrices()
        public
        view
        returns (uint256[] memory prices, uint256 totalPrice)
    {
        prices = new uint256[](components.length);
        for (uint256 i = 0; i < prices.length; i++) {
            prices[i] = getComponentPrice(i);
            totalPrice += prices[i];
        }
    }

    function getComponentPrice(uint256 order)
        public
        view
        returns (uint256 price)
    {
        return _getPrice(components[order].vault);
    }

    function getComponentUnderlying(uint256 order)
        public
        view
        returns (address[] memory)
    {
        return _getUnderlying(components[order].vault);
    }
}
