// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./PipelineAdapter.sol";
import "./interfaces/IVaultIndex.sol";
import "./interfaces/IRegistry.sol";
import "./interfaces/IFactory.sol";

contract VaultIndex is
    IVaultIndex,
    PipelineAdapter,
    ERC20Upgradeable,
    OwnableUpgradeable
{
    using SafeERC20 for IERC20;

    Component[] public components;

    uint96 public totalWeight;

    // EVENTS

    event Deposit(address account, address tokenIn, uint256 amount);

    event Withdrawal(address account, address tokenOut, uint256 amount);

    event ComponentAdded(Component component, uint256 order);

    event ComponentRemoved(Component component, uint256 order);

    // CONSTRUCTOR

    function initialize(
        string calldata name_,
        string calldata symbol_,
        address owner_,
        Component[] calldata components_
    ) external initializer {
        // Dependencies init
        __Ownable_init();
        __ERC20_init(name_, symbol_);

        // Setup fields
        registry = IRegistry(IFactory(msg.sender).registry());
        transferOwnership(owner_);
        uint96 totalWeight_;
        for (uint256 i = 0; i < components_.length; i++) {
            components.push(components_[i]);
            totalWeight_ += components_[i].targetWeight;
        }
        totalWeight = totalWeight_;
    }

    // PUBLIC FUNCTIONS

    function deposit(IERC20 tokenIn, uint256 amount) external {
        // Get component prices and total prices
        (, uint256 currentTotalPrice) = getComponentPrices();

        // Transfer token to address
        tokenIn.safeTransferFrom(msg.sender, address(this), amount);

        // Deposit each component according to it's target share
        uint256 boughtPrice;
        for (uint256 i = 0; i < components.length; i++) {
            boughtPrice += _deposit(
                components[i].vault,
                tokenIn,
                (amount * components[i].targetWeight) / totalWeight
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

        // Event
        emit Deposit(msg.sender, address(tokenIn), amount);
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

        // Event
        emit Withdrawal(msg.sender, address(tokenOut), amountOut);
    }

    // RESTRICTED PUBLIC FUNCTIONS

    function addComponent(Component memory component) external onlyOwner {
        // Add component to list
        components.push(component);
        totalWeight += component.targetWeight;

        // Rebalance to new component
        _targetComponent(components.length - 1);

        // Emit event
        emit ComponentAdded(component, components.length - 1);
    }

    function rebalanceFromTo(
        uint256 orderDecrease,
        uint256 orderIncrease,
        uint256 shareNum,
        uint256 shareDenom
    ) external onlyOwner {
        _rebalanceFromTo(orderDecrease, orderIncrease, shareNum, shareDenom);
    }

    function removeComponent(uint256 order) external onlyOwner {
        // Update weights
        totalWeight -= components[order].targetWeight;
        components[order].targetWeight = 0;

        // Rebalance
        _targetComponent(order);

        // Remove component from list and emit event
        emit ComponentRemoved(components[order], order);
        components[order] = components[components.length - 1];
        components.pop();
    }

    function targetComponent(uint256 order) external onlyOwner {
        _targetComponent(order);
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

    // PRIVATE FUNCTIONS

    function _rebalanceFromTo(
        uint256 orderDecrease,
        uint256 orderIncrease,
        uint256 shareNum,
        uint256 shareDenom
    ) private {
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
        _deposit(components[orderIncrease].vault, through, sellPrice);
    }

    function _targetComponent(uint256 order) private {
        // Get component prices and total price
        (uint256[] memory prices, uint256 totalPrice) = getComponentPrices();

        uint256 targetPrice = (totalPrice * components[order].targetWeight) /
            totalWeight;
        if (targetPrice > prices[order]) {
            uint256 diffNum = targetPrice - prices[order];
            uint256 diffDenom = totalPrice - prices[order];
            // Sell required share of each component to increase current
            for (uint256 i = 0; i < components.length; i++) {
                if (i != order) {
                    _rebalanceFromTo(i, order, diffNum, diffDenom);
                }
            }
        } else {
            // Buy other components according to their share to decrease current
            totalPrice -= prices[order];
            for (uint256 i = 0; i < components.length; i++) {
                if (i != order) {
                    _rebalanceFromTo(order, i, prices[i], totalPrice);
                    totalPrice -= prices[i];
                }
            }
        }
    }
}
