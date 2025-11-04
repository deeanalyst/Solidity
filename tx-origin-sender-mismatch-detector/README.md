# Tx Origin Sender Mismatch Detector

I've built a Drosera trap that monitors Ethereum transactions for mismatches between `tx.origin` and `msg.sender`. This is a critical security mechanism because when these two values differ, it indicates that a transaction has passed through an intermediate contract or proxy, which can be a sign of phishing attacks, malicious proxy contracts, or other security vulnerabilities.

## How It Works

This project implements a reactive monitoring system that detects when `tx.origin != msg.sender` and triggers appropriate responses. The system consists of two main components:

### Main Contract: `TxOriginMismatchTrap.sol`

The main trap contract implements the Drosera `ITrap` interface and is deployed via Drosera commands. It has two core functions:

1. **`collect()`**: This function gathers transaction data by capturing the current `tx.origin` and `msg.sender` values. It returns this data as abi-encoded bytes for analysis.

2. **`shouldRespond()`**: This function analyzes the collected data to determine if a mismatch exists. It compares `tx.origin` and `msg.sender` from the most recent data point. If they differ, it returns `true` along with the encoded mismatch data, triggering the response mechanism.

### Response Contract: `TxOriginMismatchResponse.sol`

The response contract is deployed separately using Foundry and is called by Drosera when a mismatch is detected. It:

- Emits a `MismatchDetected` event with the origin and sender addresses
- Can be extended to trigger additional security mechanisms (notifications, logging, etc.)
- All addresses are hardcoded (no constructor arguments or initialization functions)

## Key Design Principles

I've designed this trap following Drosera's infrastructure constraints:

- **No Constructor Arguments**: All addresses and values are hardcoded as constants
- **No Initialize Functions**: Drosera doesn't support initialization functions
- **No Storage**: The trap uses only temporary variables, as Drosera's infrastructure doesn't support persistent storage
- **Reactive, Not Proactive**: The trap responds to events rather than actively polling
- **Operator Whitelisting**: Operators are whitelisted in `drosera.toml`, not in the contracts themselves

## Project Structure

```
tx-origin-sender-mismatch-detector/
├── src/
│   ├── TxOriginMismatchTrap.sol      # Main trap contract (deployed via Drosera)
│   └── TxOriginMismatchResponse.sol  # Response contract (deployed via Foundry)
├── test/
│   ├── TxOriginMismatchTrap.t.sol    # Unit tests for the trap
│   ├── IntegrationTest.t.sol         # Integration tests with proxy scenarios
│   └── MockProxyContract.sol         # Mock proxy contract for testing
├── drosera.toml                      # Drosera configuration file
├── foundry.toml                      # Foundry configuration
└── README.md                         # This file
```

## Configuration

### drosera.toml

The `drosera.toml` file configures the trap deployment:

```toml
[trap]
path = "src/TxOriginMismatchTrap.sol"
response_contract = "0x0000000000000000000000000000000000000000"  # Update after deployment
response_function = "executeResponse"
whitelist = []  # Add operator addresses that can call collect()
```

**Important**: Before deploying, you need to:
1. Deploy the response contract using Foundry
2. Update the `response_contract` address in `drosera.toml`
3. Add operator addresses to the `whitelist` array

## Deployment

### Prerequisites

- Foundry (for building and testing)
- Drosera CLI (for deploying the main trap contract)
- Access to Ethereum Holesky testnet (for testing)

### Step 1: Deploy Response Contract

Deploy the response contract using Foundry:

```bash
forge script script/DeployResponse.s.sol --rpc-url holesky --broadcast
```

After deployment, note the deployed contract address.

### Step 2: Update drosera.toml

Update the `drosera.toml` file with:
- The deployed response contract address
- Operator addresses in the whitelist

### Step 3: Deploy Main Trap Contract

Deploy the main trap contract using Drosera commands:

```bash
drosera deploy
```

The main contract will be deployed with all hardcoded addresses and values.

## Testing

I've included comprehensive test suites that can be run with Foundry:

```bash
# Run all tests
forge test

# Run tests with verbose output
forge test -vv

# Run specific test file
forge test --match-path test/TxOriginMismatchTrap.t.sol
```

The test suite includes:
- Unit tests for individual functions
- Integration tests with proxy contract scenarios
- Edge case testing (zero addresses, matching addresses, etc.)
- Full flow testing (collect → shouldRespond → executeResponse)

## How the System Detects Mismatches

1. **Data Collection**: Drosera operators (whitelisted in `drosera.toml`) periodically call the `collect()` function to gather transaction data.

2. **Analysis**: The collected data is passed to `shouldRespond()`, which decodes the most recent data point and compares `tx.origin` and `msg.sender`.

3. **Detection**: If `tx.origin != msg.sender`, the function returns `true` along with encoded data containing both addresses.

4. **Response**: When a mismatch is detected, Drosera calls the response contract's `executeResponse()` function with the mismatch data.

5. **Action**: The response contract emits an event and can execute additional security measures (notifications, logging, etc.).

## Use Cases

This trap is particularly useful for detecting:

- **Phishing Attacks**: When users interact with malicious proxy contracts
- **Proxy-Based Attacks**: Unauthorized proxy contracts intercepting transactions
- **Smart Contract Vulnerabilities**: Contracts that don't properly validate call origins
- **Security Monitoring**: General monitoring of suspicious transaction patterns

## Network Support

This project is configured for the Ethereum Holesky testnet. For deployment to other networks, update the `foundry.toml` RPC endpoints accordingly.

## Development

### Building the Project

```bash
forge build
```

### Running Tests

```bash
forge test
```

### Code Quality

The project follows Solidity best practices and includes:
- Comprehensive NatSpec documentation
- Gas-optimized code
- Security-focused design patterns
- Extensive test coverage

## Limitations

- The trap is reactive and requires periodic calls to `collect()` by operators
- No persistent storage is available (all data is temporary)
- Addresses must be hardcoded (no constructor arguments)
- The monitored address is hardcoded in the contract

## Future Enhancements

Potential improvements could include:
- Support for monitoring multiple addresses
- Configurable thresholds for different types of mismatches
- Integration with external alerting systems
- Additional response mechanisms beyond event emission

## License

This project is licensed under the MIT License.

## References

- [Drosera Documentation](https://dev.drosera.io/)
- [Drosera Litepaper](https://dev.drosera.io/litepaper/)
- [Drosera Trap Examples](https://github.com/drosera-network/drosera-mcp-server/tree/main/trap-examples)

## Contributing

Contributions are welcome! Please ensure that any changes:
- Follow Drosera's infrastructure constraints
- Maintain test coverage
- Include appropriate documentation
- Follow the existing code style

## Support

For issues or questions related to:
- **Drosera**: Check the [Drosera documentation](https://dev.drosera.io/)
- **This Project**: Open an issue on the repository
- **Foundry**: Check the [Foundry documentation](https://book.getfoundry.sh/)
