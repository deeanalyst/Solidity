# Code Size Mutation Monitor Trap

I've built a Drosera trap that monitors smart contracts for unexpected changes in their bytecode size. This is a security-focused trap designed to detect potential proxy upgrades, code injection attacks, or unauthorized contract modifications that manifest as changes in the contract's code size.

## What This Project Does

This project implements a reactive monitoring system that detects when a target smart contract's bytecode size changes beyond a predefined threshold. When such a mutation is detected, the trap triggers a response contract that can emit events, log the incident, or execute other predefined security measures.

The system consists of two main components:

1. **CodeSizeMonitorTrap** - The main trap contract that monitors code size changes
2. **CodeSizeResponse** - The response contract that executes when mutations are detected

## How The System Works

The trap operates in a reactive manner, following Drosera's infrastructure principles:

### Main Trap Contract (CodeSizeMonitorTrap.sol)

The main trap contract is deployed using Drosera's deployment system and contains all the monitoring logic:

1. **Data Collection**: The `collect()` function reads the current bytecode size of a hardcoded target contract address using the `extcodesize` assembly opcode.

2. **Mutation Detection**: The `shouldRespond()` function compares code sizes from multiple collection points (at least two data points are required). It calculates the absolute difference between the old and new code sizes.

3. **Threshold Triggering**: If the code size change exceeds the hardcoded threshold (100 bytes by default), the trap returns `true` along with encoded data containing the target address, old size, new size, and the difference.

### Response Contract (CodeSizeResponse.sol)

The response contract is deployed separately using Foundry and handles the response when a mutation is detected:

1. **Event Emission**: When called by Drosera, it emits a `CodeSizeMutationDetected` event containing all relevant information about the mutation.

2. **Extensibility**: The contract can be extended to include additional response logic such as logging to external systems, pausing related contracts, or triggering alerts.

## Key Design Decisions

I've made several important design decisions to ensure compatibility with Drosera's infrastructure:

- **No Constructor Arguments**: Both contracts are designed without constructors that require arguments. All addresses and values are hardcoded as constants in the contract.

- **No Initialize Functions**: The contracts don't use initialization patterns, as Drosera doesn't support them.

- **No Persistent Storage**: The trap doesn't use storage variables. All data is handled temporarily during function execution, making the trap stateless and compatible with Drosera's reactive model.

- **Hardcoded Configuration**: The target contract address (`TARGET_CONTRACT`) and size threshold (`SIZE_THRESHOLD`) are hardcoded as constants. These must be set before deployment.

- **Whitelist Management**: Operators are whitelisted in the `drosera.toml` configuration file, not in the contract itself. This follows Drosera's infrastructure pattern.

## Project Structure

```
.
├── src/
│   ├── CodeSizeMonitorTrap.sol      # Main trap contract
│   ├── CodeSizeResponse.sol         # Response contract
│   └── mocks/
│       └── MockTargetContract.sol   # Mock contracts for testing
├── test/
│   ├── CodeSizeMonitorTrap.t.sol    # Tests for main trap
│   └── CodeSizeResponse.t.sol       # Tests for response contract
├── scripts/
│   └── DeployCodeSizeResponse.s.sol # Deployment script for response contract
├── foundry.toml                     # Foundry configuration
├── drosera.toml                     # Drosera configuration (update after deployment)
└── remappings.txt                   # Solidity import remappings
```

## Setup and Installation

### Prerequisites

- Foundry (for compiling and testing)
- Bun or npm (for dependency management)
- Drosera CLI (for deploying the main trap)

### Installation

```bash
# Install Foundry
curl -L https://foundry.paradigm.xyz | bash
foundryup

# Install dependencies
bun install  # or npm install

# Install Drosera CLI
curl -L https://app.drosera.io/install | bash
droseraup
```

## Configuration

### Before Deployment

1. **Update Target Contract Address**: In `src/CodeSizeMonitorTrap.sol`, update the `TARGET_CONTRACT` constant with the address of the contract you want to monitor:
   ```solidity
   address public constant TARGET_CONTRACT = 0xYourTargetContractAddress;
   ```

2. **Adjust Size Threshold**: If needed, modify the `SIZE_THRESHOLD` constant (default is 100 bytes):
   ```solidity
   uint256 public constant SIZE_THRESHOLD = 100; // bytes
   ```

### After Deployment

Once you've deployed the response contract, update `drosera.toml`:

```toml
[traps.code_size_monitor]
path = "out/CodeSizeMonitorTrap.sol/CodeSizeMonitorTrap.json"
response_contract = "0xYourDeployedResponseContractAddress"
response_function = "respond(bytes)"
cooldown_period_blocks = 33
min_number_of_operators = 1
max_number_of_operators = 2
block_sample_size = 10
private_trap = true
whitelist = ["0xOperatorAddress1", "0xOperatorAddress2"]  # Add operator addresses here
```

## Deployment

### Deploy Response Contract

First, deploy the response contract using Foundry:

```bash
# Set your private key as an environment variable
export PRIVATE_KEY=0xYourPrivateKey

# Deploy to Hoodi network
forge script script/DeployCodeSizeResponse.s.sol:DeployCodeSizeResponse \
  --rpc-url hoodi \
  --broadcast \
  --verify
```

Save the deployed contract address - you'll need it for the `drosera.toml` configuration.

### Deploy Main Trap Contract

After configuring `drosera.toml`, deploy the main trap:

```bash
# Compile the contract
forge build

# Deploy using Drosera CLI
DROSERA_PRIVATE_KEY=0xYourPrivateKey drosera apply
```

## Testing

I've included comprehensive test suites for both contracts. All tests pass successfully:

```bash
# Run all tests
forge test

# Run with verbose output
forge test -vv

# Run specific test file
forge test --match-path test/CodeSizeMonitorTrap.t.sol
```

### Test Coverage

The test suite includes:

- **CodeSizeMonitorTrap Tests**:
  - Data collection verification
  - Threshold detection logic
  - Size increase and decrease scenarios
  - Invalid data handling
  - Integration tests with mock contracts

- **CodeSizeResponse Tests**:
  - Event emission verification
  - Data handling with various inputs
  - Edge cases (zero address, large differences, etc.)

### Running Tests

```bash
# Run all tests
forge test

# Run with gas reporting
forge test --gas-report

# Run specific test
forge test --match-test test_ShouldRespond_ReturnsTrue_WhenSizeChangeExceedsThreshold
```

## How Drosera Executes This Trap

1. **Collection Phase**: Drosera operators call the `collect()` function at regular intervals, gathering the current code size of the target contract.

2. **Analysis Phase**: Drosera passes the collected data (at least 2 data points) to `shouldRespond()` to determine if a response is needed.

3. **Response Phase**: If `shouldRespond()` returns `true`, Drosera calls the response contract's `respond()` function with the encoded mutation data.

4. **Event Emission**: The response contract emits an event that can be monitored by external systems or indexed for alerting.

## Security Considerations

- **False Positives**: Legitimate contract upgrades will trigger the trap. Ensure your threshold is appropriate for your use case.

- **Target Address**: The target contract address is hardcoded. Make sure it's correct before deployment, as redeployment is required to change it.

- **Threshold Sensitivity**: A threshold that's too low may cause false positives, while one that's too high may miss subtle attacks.

- **Network Compatibility**: This trap is designed for the Ethereum Hoodi network. For other networks, update the RPC endpoints in `foundry.toml` and `drosera.toml`.

## Extending the Trap

### Adding More Monitoring Logic

You can extend the trap to monitor multiple contracts or add additional conditions:

```solidity
// Monitor multiple contracts
address public constant TARGET_CONTRACT_1 = 0x...;
address public constant TARGET_CONTRACT_2 = 0x...;
```

### Enhancing the Response Contract

Add custom response logic to the response contract:

```solidity
function respond(bytes calldata data) external {
    // Decode data
    (address target, uint256 oldSize, uint256 newSize, uint256 diff) = 
        abi.decode(data, (address, uint256, uint256, uint256));
    
    // Emit event
    emit CodeSizeMutationDetected(target, oldSize, newSize, diff, block.timestamp);
    
    // Add custom logic here
    // - Call external APIs
    // - Pause related contracts
    // - Trigger alerts
}
```

## Troubleshooting

### Contract Compilation Issues

If you encounter compilation errors:
- Ensure all dependencies are installed: `bun install`
- Check Solidity version matches `foundry.toml` (0.8.20)
- Verify remappings in `remappings.txt` are correct

### Deployment Issues

- Verify your private key has sufficient funds on Hoodi network
- Check that the target contract address is valid and has code
- Ensure `drosera.toml` is properly formatted

### Test Failures

- Run `forge clean` and rebuild: `forge build`
- Check that mock contracts are properly deployed in tests
- Verify test addresses match the hardcoded constants

## Contributing

This is a focused security monitoring tool. When extending:

1. Maintain Drosera compatibility (no constructors, no storage, no initialize functions)
2. Keep all configuration hardcoded
3. Add comprehensive tests for new features
4. Update this README with any significant changes

## References

- [Drosera Documentation](https://dev.drosera.io)
- [Drosera Litepaper](https://dev.drosera.io/litepaper/)
- [Drosera Trap Examples](https://github.com/drosera-network/drosera-mcp-server/tree/main/trap-examples)
- [Foundry Documentation](https://book.getfoundry.sh/)

## License

MIT License - See LICENSE file for details

---

**Note**: This trap is designed to be reactive and will only trigger when code size mutations are detected. It does not proactively scan for vulnerabilities but monitors for changes that may indicate unauthorized modifications or upgrades.