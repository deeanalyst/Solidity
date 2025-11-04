# Token Pair Price Divergence Trap

I've built a Drosera trap that monitors token balance changes and price movements for a specific address, triggering a response when both thresholds are crossed simultaneously. This project demonstrates how to build reactive monitoring systems on the Drosera network.

[![view - Documentation](https://img.shields.io/badge/view-Documentation-blue?style=for-the-badge)](https://dev.drosera.io "Project documentation")
[![Twitter](https://img.shields.io/twitter/follow/DroseraNetwork?style=for-the-badge)](https://x.com/DroseraNetwork)

## What This Project Does

I've created a monitoring system that watches for significant changes in both token balance and price for a tracked address. The trap only triggers when **both** conditions are met:
- The token balance change exceeds a predefined threshold (default: 1000 tokens)
- The price change exceeds a predefined threshold (default: 50 USD, using Chainlink price feeds)

This dual-threshold approach ensures that the trap only activates when there's genuine market activity combined with price movement, reducing false positives from simple balance transfers or minor price fluctuations.

## How the System Works

The system consists of two main components:

### 1. Main Trap Contract (`TokenPairPriceDivergenceTrap.sol`)

This is the contract deployed by Drosera that monitors the blockchain state. It implements the `ITrap` interface with two key functions:

- **`collect()`**: Called by Drosera operators to gather data from the blockchain. It:
  - Checks the ERC-20 token balance of the tracked address
  - Fetches the latest price from a Chainlink price feed aggregator
  - Returns encoded data containing the address, balance, and price

- **`shouldRespond()`**: Analyzes collected data points to determine if a response should be triggered. It:
  - Compares data from two different time points (typically sequential blocks)
  - Calculates the absolute difference in both balance and price
  - Triggers only if **both** differences exceed their respective thresholds (using `&&` logic)
  - Returns encoded response data if triggered

**Important Design Decisions:**
- All addresses and thresholds are hardcoded as constants (no constructor arguments)
- Uses `IERC20.balanceOf()` for accurate token balance monitoring (not ETH balance)
- Integrates with Chainlink's `AggregatorV3Interface` for reliable price feeds
- No storage or initialization functions - purely reactive and stateless

### 2. Response Contract (`TokenPairPriceDivergenceResponse.sol`)

This contract handles the response when the trap triggers. It:
- Emits an event with all relevant divergence data (balance before/after, price before/after)
- Can be extended with custom response logic (though Drosera emphasizes reactive monitoring)
- Deployed separately using Foundry (not through Drosera)

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                    Drosera Network                       │
│  ┌───────────────────────────────────────────────────┐  │
│  │  Operators call collect() on each block           │  │
│  │  Gather data: [balance, price]                    │  │
│  └───────────────────────────────────────────────────┘  │
│                          ↓                               │
│  ┌───────────────────────────────────────────────────┐  │
│  │  shouldRespond() analyzes data points             │  │
│  │  Checks: balanceDiff > threshold &&               │  │
│  │          priceDiff > threshold                    │  │
│  └───────────────────────────────────────────────────┘  │
│                          ↓                               │
│              If triggered: call response contract        │
└─────────────────────────────────────────────────────────┘
                          ↓
        ┌─────────────────────────────────────┐
        │  Response Contract (on-chain)       │
        │  - Emits PriceDivergenceDetected    │
        │  - Logs all relevant data           │
        └─────────────────────────────────────┘
```

## Key Features

1. **Dual-Threshold Monitoring**: Both balance and price must cross thresholds simultaneously
2. **ERC-20 Token Support**: Properly monitors token balances (not just ETH)
3. **Chainlink Integration**: Uses reliable Chainlink price feeds for accurate price data
4. **Reactive Design**: Follows Drosera's reactive philosophy - no proactive actions
5. **No Storage**: All operations use temporary data only, no persistent state
6. **Hardcoded Configuration**: All addresses and thresholds are constants, compatible with Drosera's deployment model

## Project Structure

```
├── src/
│   ├── TokenPairPriceDivergenceTrap.sol      # Main trap contract
│   ├── TokenPairPriceDivergenceResponse.sol  # Response contract
│   └── mocks/
│       ├── MockERC20.sol                     # Mock ERC20 for testing
│       └── MockAggregatorV3.sol              # Mock Chainlink feed for testing
├── test/
│   └── TokenPairPriceDivergenceTrap.t.sol    # Comprehensive test suite
├── scripts/
│   └── DeployTokenPairPriceDivergenceResponse.s.sol  # Deployment script
├── drosera.toml                              # Drosera configuration
└── foundry.toml                              # Foundry configuration
```

## Configuration

Before deployment, you need to update the hardcoded addresses in `TokenPairPriceDivergenceTrap.sol`:

```solidity
address public constant trackedAddress = 0x...;  // Address to monitor
IERC20 public constant token = IERC20(0x...);    // ERC20 token address
AggregatorV3Interface public constant priceFeed = AggregatorV3Interface(0x...); // Chainlink feed
```

You can also adjust thresholds:

```solidity
uint256 public constant BALANCE_THRESHOLD = 1000 * 1e18;  // Token amount threshold
int256 public constant PRICE_THRESHOLD = 50e8;            // Price change threshold (in feed decimals)
```

## Deployment Instructions

### Prerequisites

```bash
# Install Foundry
curl -L https://foundry.paradigm.xyz | bash
foundryup

# Install dependencies (using Bun or npm)
bun install
# or
npm install

# Install Drosera CLI
curl -L https://app.drosera.io/install | bash
droseraup
```

### Step 1: Update Hardcoded Addresses

Edit `src/TokenPairPriceDivergenceTrap.sol` and replace the placeholder addresses:
- `trackedAddress`: The address whose token balance you want to monitor
- `token`: The ERC-20 token contract address
- `priceFeed`: The Chainlink AggregatorV3 price feed address

### Step 2: Deploy Response Contract

Deploy the response contract using Foundry:

```bash
# Compile contracts
forge build

# Deploy response contract (update RPC URL for Hoodi network)
forge script scripts/DeployTokenPairPriceDivergenceResponse.s.sol:DeployTokenPairPriceDivergenceResponse \
  --rpc-url https://ethereum-hoodi-rpc.publicnode.com \
  --broadcast \
  --private-key <your-private-key>
```

After deployment, note the response contract address.

### Step 3: Update drosera.toml

Update the `drosera.toml` file with the deployed response contract address:

```toml
response_contract = "0x..."  # Your deployed response contract address
```

Add operator addresses to the whitelist if needed:

```toml
whitelist = ["0x...", "0x..."]  # Operator addresses
```

### Step 4: Deploy Main Trap Contract

Deploy the main trap using Drosera:

```bash
# Compile the trap
forge build

# Deploy using Drosera
DROSERA_PRIVATE_KEY=0x... drosera apply
```

The Drosera CLI will automatically add the deployed trap address to `drosera.toml`.

## Testing

I've included comprehensive tests that verify:

- ✅ Correct data collection from mock contracts
- ✅ Trigger logic when both thresholds are crossed
- ✅ No trigger when only balance threshold is crossed
- ✅ No trigger when only price threshold is crossed
- ✅ No trigger when neither threshold is crossed
- ✅ Proper handling of insufficient data
- ✅ Response contract event emission
- ✅ Absolute value calculation for price differences

Run the tests with:

```bash
forge test -vv
```

For more verbose output:

```bash
forge test -vvv
```

All tests should pass successfully, demonstrating that the trap logic works correctly.

## How Drosera Works With This Trap

1. **Data Collection**: Drosera operators call `collect()` on each block, gathering balance and price data
2. **Data Aggregation**: Multiple data points are collected across the configured `block_sample_size`
3. **Analysis**: The `shouldRespond()` function is called with the collected data points
4. **Response**: If triggered, Drosera calls the response contract's `handlePriceDivergence()` function
5. **Monitoring**: The response contract emits events that can be monitored off-chain

The trap is **reactive** - it only responds to conditions that have already occurred, never taking proactive actions. This aligns with Drosera's infrastructure design.

## Important Notes

- **No Constructor Arguments**: The main trap contract uses hardcoded constants because Drosera doesn't support constructor arguments
- **No Initialize Functions**: Drosera doesn't allow initialization functions, so all configuration is hardcoded
- **No Storage**: The trap doesn't use persistent storage - all data is temporary and calculated on-the-fly
- **Whitelist**: Operators are whitelisted in `drosera.toml`, not in the contract itself
- **Network**: This project is configured for Ethereum Hoodi network (chain ID: 560048)

## Extending the Response Contract

The response contract currently only emits events. You can extend it to:
- Log data to IPFS or other storage systems
- Trigger alerts via webhooks
- Send notifications to monitoring systems

Remember: Keep it reactive! Don't add proactive trading logic or automated actions that could be exploited.

## Troubleshooting

If tests fail:
1. Ensure all dependencies are installed: `bun install`
2. Check that Foundry is up to date: `foundryup`
3. Verify Solidity version compatibility (0.8.20+)

If deployment fails:
1. Verify you have sufficient funds on Hoodi network
2. Check that all placeholder addresses have been updated
3. Ensure the response contract is deployed before updating `drosera.toml`

## License

MIT

## Contributing

Feel free to fork this project and adapt it for your own monitoring needs. Remember to:
- Update hardcoded addresses for your use case
- Adjust thresholds based on your token's characteristics
- Test thoroughly before deploying to mainnet

## Resources

- [Drosera Documentation](https://dev.drosera.io)
- [Drosera Litepaper](https://dev.drosera.io/litepaper/)
- [Drosera Trap Examples](https://github.com/drosera-network/drosera-mcp-server/tree/main/trap-examples)
- [Chainlink Price Feeds](https://docs.chain.link/data-feeds)

---

Built with ❤️ using Drosera's reactive monitoring infrastructure
