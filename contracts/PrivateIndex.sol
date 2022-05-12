//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract PrivateIndex is Ownable {
    using SafeERC20 for IERC20;

    IIndexFactory public factory;

    struct Component {
        address vault;
    }

    Component[] public components;

    // CONSTRUCTOR

    constructor(address owner_, Component[] memory components_) {
        transferOwnership(owner_);
        factory = IIndexFactory(msg.sender);
        components = components_;
    }

    // PUBLIC FUNCTIONS

    function buy(IERC20 with, uint256 amount) external {
        // Get component prices and total prices
        (uint256 totalPrice, uint256[] memory prices) = getComponentPrices();
        // Buy each component according to it's current share
        for (uint256 i = 0; i < components.length; i++) {
            buyComponent(i, with, (amount * prices[i]) / totalPrice);
        }
    }

    function sell(IERC20 to, uint256 share) external returns (uint256 price) {
        for (uint256 i = 0; i < components.length; i++) {
            price += sellComponent(i, to, share);
        }
    }

    function buyComponent(
        uint256 order,
        IERC20 with,
        uint256 amount
    ) public {
        // Check component coins
        // Buy component coins using `with`
        // Deposit coins to DEX
        // Deposit LP tokens to vault
    }

    function sellComponent(
        uint256 order,
        IERC20 to,
        uint256 share
    ) public returns (uint256 price) {
        // Withdraw LP tokens from vault
        // Burn LP tokens for underlying
        // Swap underlying to `to`
    }

    function addComponentAndBuy(
        Component memory component,
        IERC20 with,
        uint256 amount
    ) external {
        components.push(component);
        buyComponent(order, with, amount);
    }

    function rebalanceComponent(
        uint256 orderDecrease,
        uint256 orderIncrease,
        uint256 share
    ) external {
        IERC20 through = IERC20(getComponentUnderlying(orderIncrease)[0]);
        uint256 sellPrice = sellComponent(orderDecrease, through, share);
        buyComponent(orderIncrease, through, sellPrice);
    }

    // PUBLIC VIEW FUNCTIONS

    function getComponentPrices()
        public
        view
        returns (uint256[] memory prices, uint256 totalPrice)
    {
        prices = uint256[](components.length);
        for (uint256 i = 0; i < result.length; i++) {
            prices[i] = getComponentsAmount(i, token);
            totalPrice += prices[i];
        }
    }

    function getComponentPrice(uint256 order)
        public
        view
        returns (uint256 price)
    {
        // Get component underlying balance
        // Convert it to USD using price feed
        return 0;
    }

    function getComponentUnderlying(uint256 order)
        public
        view
        returns (address[] memory)
    {
        // Get component underlying coins
    }
}
