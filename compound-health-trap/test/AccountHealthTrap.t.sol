// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {AccountHealthTrap} from "../src/AccountHealthTrap.sol";
import {MockComptroller} from "./mock/MockComptroller.sol";

contract AccountHealthTrapTest is Test {
    AccountHealthTrap internal trap;
    MockComptroller internal mockComptroller;
    address internal constant MOCK_COMPTROLLER_ADDRESS = 0x3279cf72FD2bFbd2604764B625A68646E6cd4E98;

    // --- Test Users ---
    address internal accountToMonitor = 0x6aaEE634A4Aff5960fA9a8970E0145E35Ef9E039;

    // --- Constants ---
    uint256 internal constant SAFE_LIQUIDITY = 2000 * 1e18;
    uint256 internal constant RISKY_LIQUIDITY = 500 * 1e18;

    /// @notice Sets up the test environment before each test case.
    function setUp() public {
        mockComptroller = new MockComptroller();
        vm.etch(MOCK_COMPTROLLER_ADDRESS, address(mockComptroller).code);
        trap = new AccountHealthTrap();
    }

    // --- Core Logic Tests ---
    function test_ShouldRespond_WhenLiquidityIsBelowThreshold() public {
        // Arrange
        bytes memory collectedData = abi.encode(RISKY_LIQUIDITY, accountToMonitor);
        // Act
        (bool should, bytes memory responseData) = trap.shouldRespond(collectedData);
        // Assert
        assertTrue(should, "Should respond when liquidity is low");
        assertEq(responseData, collectedData, "Response data should match collected data");
    }

    function test_ShouldNotRespond_WhenLiquidityIsAboveThreshold() public {
        // Arrange
        bytes memory collectedData = abi.encode(SAFE_LIQUIDITY, accountToMonitor);
        // Act
        (bool should, ) = trap.shouldRespond(collectedData);
        // Assert
        assertFalse(should, "Should not respond when liquidity is high");
    }

    function test_Collect_ReturnsCorrectData() public {
        // Arrange
        vm.prank(MOCK_COMPTROLLER_ADDRESS);
        MockComptroller(MOCK_COMPTROLLER_ADDRESS).setMockLiquidity(SAFE_LIQUIDITY);
        // Act
        bytes memory collectedData = trap.collect();
        // Assert
        (uint256 liquidity, address account) = abi.decode(collectedData, (uint256, address));
        assertEq(liquidity, SAFE_LIQUIDITY, "Collected liquidity should be correct");
        assertEq(account, accountToMonitor, "Collected account should be correct");
    }
}
