// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IComptroller} from "./interfaces/IComptroller.sol";

/// @title AccountHealthTrap
/// @notice A Drosera trap that monitors the health of a specific account on Compound.
/// @dev Hardcodes the addresses for the comptroller and the account to monitor.
contract AccountHealthTrap {
    // --- State ---

    // Using the addresses of our deployed MOCK contracts for testing on Hoodi
    IComptroller public constant comptroller = IComptroller(0x3279cf72FD2bFbd2604764B625A68646E6cd4E98);
    address public constant accountToMonitor = 0x6aaEE634A4Aff5960fA9a8970E0145E35Ef9E039;

    uint256 private constant LIQUIDITY_THRESHOLD = 1000 * 1e18; // Example: 1000 USD

    // --- Functions ---

    /// @notice Collects the account liquidity data from the Compound protocol.
    /// @dev This function can be called by any Drosera node.
    /// @return abi.encode(liquidity, account) - The encoded liquidity and address of the whale account.
    function collect() external view returns (bytes memory) {
        (, uint256 liquidity, ) = comptroller.getAccountLiquidity(accountToMonitor);
        return abi.encode(liquidity, accountToMonitor);
    }

    /// @notice Determines if a response should be triggered based on the collected data.
    /// @param data The collected data from the `collect` function (encoded account liquidity and address).
    /// @return shouldRespond - True if the account's liquidity is below the threshold.
    /// @return responseData - The data to be passed to the response contract.
    function shouldRespond(bytes calldata data) external view returns (bool, bytes memory) {
        (uint256 liquidity, ) = abi.decode(data, (uint256, address));
        bool should = liquidity < LIQUIDITY_THRESHOLD;
        return (should, data);
    }
}