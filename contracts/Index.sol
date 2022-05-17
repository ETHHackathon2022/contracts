//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./PipelineAdapter.sol";
import "./interfaces/IIndex.sol";
import "./interfaces/IRegistry.sol";
import "./interfaces/IFactory.sol";

import "hardhat/console.sol";

contract Index is
    IIndex,
    PipelineAdapter,
    ERC20Upgradeable,
    OwnableUpgradeable
{
    using SafeERC20 for IERC20;

    Component[] public components;

    // CONSTRUCTOR

    function initialize(
        string calldata name_,
        string calldata symbol_,
        address owner_,
        Component[] calldata components_,
        uint256[] calldata weights_,
        IERC20 tokenIn,
        uint256 amount
    ) external initializer {
        require(components_.length == weights_.length, "Lenght mismatch");

        // Dependencies init
        __Ownable_init();
        __ERC20_init(name_, symbol_);

        // Setup fields
        registry = IRegistry(IFactory(msg.sender).registry());
        transferOwnership(owner_);

        // Calculate total weight and add all components
        uint256 totalWeight;
        for (uint256 i = 0; i < weights_.length; i++) {
            totalWeight += weights_[i];
            components.push(components_[i]);
        }

        // Deposit to components with given weights
        _depositAllComponents(weights_, totalWeight, 0, tokenIn, amount);
    }

    // PUBLIC FUNCTIONS

    function deposit(IERC20 tokenIn, uint256 amount) external {
        // Get component prices and total prices
        (uint256[] memory prices, uint256 totalPrice) = getComponentPrices();

        // Transfer token to address
        tokenIn.safeTransferFrom(msg.sender, address(this), amount);

        // Deposit to all components with current price share weights
        _depositAllComponents(prices, totalPrice, totalPrice, tokenIn, amount);
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

    // INTERNAL FUNCTIONS

    function _depositAllComponents(
        uint256[] memory weights,
        uint256 totalWeight,
        uint256 currentTotalPrice,
        IERC20 tokenIn,
        uint256 amount
    ) private {
        console.log("Using token in %s", address(tokenIn));

        // Deposit each component according to it's weight
        uint256 boughtPrice;
        for (uint256 i = 0; i < components.length; i++) {
            console.log("Depositing to component %s", components[i].vault);

            boughtPrice += _deposit(
                components[i].vault,
                tokenIn,
                (amount * weights[i]) / totalWeight
            );
        }

        // Mint i-tokens according to relating of bought price to current total price
        if (currentTotalPrice == 0) {
            _mint(msg.sender, boughtPrice);
        } else {
            _mint(
                msg.sender,
                (totalSupply() * boughtPrice) / currentTotalPrice
            );
        }
    }
}
