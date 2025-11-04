// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @notice Code Size Response Contract — handles responses when code size mutations are detected
/// @dev This contract is deployed via Foundry and called by Drosera when the trap triggers
contract CodeSizeResponse {
    /// @notice Event emitted when a code size mutation is detected
    event CodeSizeMutationDetected(
        address indexed targetContract,
        uint256 oldSize,
        uint256 newSize,
        uint256 sizeDifference,
        uint256 timestamp
    );

    /// @notice Executes the response logic when triggered by the trap
    /// @param data Encoded data containing target contract address, old size, new size, and difference
    /// @dev This function is called by Drosera when the trap detects a code size change
    function respond(bytes calldata data) external {
        (address targetContract, uint256 oldSize, uint256 newSize, uint256 sizeDiff) = 
            abi.decode(data, (address, uint256, uint256, uint256));

        // Emit event with the mutation details
        emit CodeSizeMutationDetected(
            targetContract,
            oldSize,
            newSize,
            sizeDiff,
            block.timestamp
        );

        // Additional response logic can be added here
        // For example: logging to an external system, pausing contracts, etc.
    }
}
