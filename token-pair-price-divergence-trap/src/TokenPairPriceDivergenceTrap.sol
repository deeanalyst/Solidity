// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

interface AggregatorV3Interface {
    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}

/// @notice Token Pair Price Divergence Trap — monitors token balance + price feed changes
/// @dev Both balance and price thresholds must be crossed (using &&) for the trap to trigger
contract TokenPairPriceDivergenceTrap is ITrap {
    // Hardcoded addresses - replace with actual addresses before deployment
    address public constant trackedAddress = 0xF38eED066703d093B20Be0A9D9fcC8684F64cdc4;
    IERC20 public constant token = IERC20(0x0000000000000000000000000000000000000000); // ERC20 token address placeholder
    AggregatorV3Interface public constant priceFeed = AggregatorV3Interface(0x0000000000000000000000000000000000000000); // Chainlink feed placeholder

    // Hardcoded thresholds - adjust as needed
    uint256 public constant BALANCE_THRESHOLD = 1000 * 1e18; // 1000 tokens (adjust decimals)
    int256 public constant PRICE_THRESHOLD = 50e8;           // 50 USD (adjust decimals)

    function collect() external view override returns (bytes memory) {
        uint256 tokenBalance = token.balanceOf(trackedAddress);
        (, int256 price,,,) = priceFeed.latestRoundData();
        return abi.encode(trackedAddress, tokenBalance, price);
    }

    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        if (data.length < 2) return (false, "");

        (address tracked0, uint256 balance0, int256 price0) = abi.decode(data[0], (address, uint256, int256));
        (address tracked1, uint256 balance1, int256 price1) = abi.decode(data[1], (address, uint256, int256));

        uint256 balanceDiff = balance1 > balance0 ? balance1 - balance0 : balance0 - balance1;
        int256 priceDiff = abs(price1 - price0);

        // Both thresholds must be crossed (using &&)
        bool triggered = (balanceDiff > BALANCE_THRESHOLD) && (priceDiff > PRICE_THRESHOLD);

        if (triggered) {
            return (true, abi.encode(tracked1, balance0, balance1, price0, price1));
        }

        return (false, "");
    }

    function abs(int256 x) internal pure returns (int256) {
        return x >= 0 ? x : -x;
    }
}

