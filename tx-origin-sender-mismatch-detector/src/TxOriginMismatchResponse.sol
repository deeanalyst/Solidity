// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title TxOriginMismatchResponse
/// @notice Response contract that executes actions when a tx.origin/msg.sender mismatch is detected
/// @dev This contract is deployed via Foundry and called by Drosera when the trap is triggered
contract TxOriginMismatchResponse {
    /// @notice Hardcoded address to receive notifications or alerts
    /// @dev This address can be an alert service, monitoring system, or admin address
    address public constant alertRecipient = 0x1234567890123456789012345678901234567890;

    /// @notice Event emitted when a mismatch is detected and response is executed
    /// @param origin The original transaction origin address
    /// @param sender The immediate sender (msg.sender) address
    /// @param timestamp The block timestamp when the response was executed
    event MismatchDetected(
        address indexed origin,
        address indexed sender,
        uint256 timestamp
    );

    /// @notice Executes the response action when a mismatch is detected
    /// @dev This function is called by Drosera when shouldRespond returns true
    /// @dev The function parameters are decoded from the response data returned by shouldRespond
    /// @param origin The original transaction origin address
    /// @param sender The immediate sender (msg.sender) address
    function executeResponse(
        address origin,
        address sender
    ) external {
        // Emit event for logging and monitoring
        emit MismatchDetected(origin, sender, block.timestamp);

        // Additional response logic can be added here:
        // - Send notifications to alertRecipient
        // - Trigger other security mechanisms
        // - Log to external monitoring systems
        // Note: All addresses must be hardcoded, no storage allowed
    }
}

