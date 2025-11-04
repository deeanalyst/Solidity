// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";

/// @notice Code Size Mutation Monitor Trap — monitors changes in contract bytecode size
/// @dev This trap detects when a target contract's code size changes unexpectedly,
///      which could indicate proxy upgrades, code injection, or unauthorized modifications.
contract CodeSizeMonitorTrap is ITrap {
    /// @notice Hardcoded target contract address to monitor
    address public constant TARGET_CONTRACT = 0x1234567890123456789012345678901234567890;
    
    /// @notice Hardcoded threshold for code size change detection (in bytes)
    /// @dev If the code size changes by more than this value, the trap triggers
    uint256 public constant SIZE_THRESHOLD = 100;

    /// @notice Collects the current code size of the target contract
    /// @return Encoded data containing the target contract address and its current code size
    function collect() external view override returns (bytes memory) {
        uint256 codeSize = getCodeSize(TARGET_CONTRACT);
        return abi.encode(TARGET_CONTRACT, codeSize);
    }

    /// @notice Determines if a response should be triggered based on code size changes
    /// @param data Array of collected data from multiple collection points
    /// @return A tuple indicating whether to respond and the encoded response data
    /// @dev Compares code sizes between collection points and triggers if change exceeds threshold
    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        // Need at least 2 data points to compare
        if (data.length < 2) return (false, "");

        // Decode the first collection point
        (address target0, uint256 size0) = abi.decode(data[0], (address, uint256));
        
        // Decode the second (most recent) collection point
        (address target1, uint256 size1) = abi.decode(data[1], (address, uint256));

        // Ensure we're monitoring the same contract
        require(target0 == TARGET_CONTRACT && target1 == TARGET_CONTRACT, "Invalid target address");

        // Calculate the absolute difference in code size
        uint256 sizeDiff = size1 > size0 ? size1 - size0 : size0 - size1;

        // Trigger if the change exceeds the threshold
        bool triggered = sizeDiff > SIZE_THRESHOLD;

        if (triggered) {
            // Return the target address, old size, and new size
            return (true, abi.encode(TARGET_CONTRACT, size0, size1, sizeDiff));
        }

        return (false, "");
    }

    /// @notice Internal helper function to get the code size of an address
    /// @param _addr The address to check
    /// @return The code size in bytes
    function getCodeSize(address _addr) internal view returns (uint256) {
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        return size;
    }
}
