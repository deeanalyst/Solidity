// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";

/// @title TxOriginMismatchTrap
/// @notice A Drosera trap that detects when tx.origin != msg.sender, indicating potential phishing or proxy-based attacks
/// @dev This trap is reactive and monitors transactions for mismatches between transaction origin and sender
contract TxOriginMismatchTrap is ITrap {
    /// @notice Hardcoded address to monitor for tx.origin and msg.sender mismatches
    /// @dev This address is monitored for potential phishing or proxy-based attack patterns
    address public constant monitoredAddress = 0xF38eED066703d093B20Be0A9D9fcC8684F64cdc4;

    /// @notice Collects transaction origin and sender data for monitoring
    /// @dev This function is called by Drosera operators (whitelisted in drosera.toml) to gather data
    /// @return abi-encoded data containing tx.origin and msg.sender
    function collect() external view override returns (bytes memory) {
        // Collect transaction origin and sender - reactive data collection
        return abi.encode(tx.origin, msg.sender);
    }

    /// @notice Determines if the trap should respond based on collected data
    /// @dev Compares tx.origin and msg.sender from collected data to detect mismatches
    /// @dev The data array is arranged where data[0] is the most recent and data[length-1] is the oldest
    /// @param data Array of abi-encoded data collected from previous collect() calls
    /// @return shouldTrigger Boolean indicating if a response should be triggered
    /// @return responseData Abi-encoded data to pass to the response contract if triggered
    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        // Need at least one data point to check for mismatch
        if (data.length < 1) return (false, "");

        // Decode the most recent data point (index 0 is most recent)
        (address origin, address sender) = abi.decode(data[0], (address, address));

        // Check for mismatch between tx.origin and msg.sender
        // A mismatch indicates the transaction passed through a proxy or intermediate contract
        // This can be a sign of phishing attacks or malicious proxy contracts
        bool mismatch = origin != sender;

        if (mismatch) {
            // Return true with encoded data containing origin and sender for response contract
            return (true, abi.encode(origin, sender));
        }

        return (false, "");
    }
}

