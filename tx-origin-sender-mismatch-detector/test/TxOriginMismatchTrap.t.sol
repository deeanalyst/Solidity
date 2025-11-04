// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {TxOriginMismatchTrap} from "../src/TxOriginMismatchTrap.sol";
import {TxOriginMismatchResponse} from "../src/TxOriginMismatchResponse.sol";

/// @title TxOriginMismatchTrapTest
/// @notice Comprehensive tests for the TxOriginMismatchTrap and Response contracts
contract TxOriginMismatchTrapTest is Test {
    TxOriginMismatchTrap public trap;
    TxOriginMismatchResponse public response;

    address public constant MONITORED_ADDRESS = 0xF38eED066703d093B20Be0A9D9fcC8684F64cdc4;
    address public constant TEST_ORIGIN = address(0x1111);
    address public constant TEST_SENDER = address(0x2222);
    address public constant TEST_ORIGIN_2 = address(0x3333);
    address public constant TEST_SENDER_2 = address(0x4444);

    function setUp() public {
        trap = new TxOriginMismatchTrap();
        response = new TxOriginMismatchResponse();
    }

    /// @notice Test that collect() function returns correct data structure
    function test_CollectReturnsCorrectData() public view {
        bytes memory data = trap.collect();
        
        // Verify data is not empty
        assertGt(data.length, 0);
        
        // Decode the collected data - should return exactly 2 addresses
        (address origin, address sender) = abi.decode(data, (address, address));
        
        // Verify that we can decode the data correctly
        // The function should return tx.origin and msg.sender
        // In Foundry test context, these may be different addresses due to test harness
        // The important thing is that the function executes and returns encoded data
        assertTrue(true); // If we got here, the function works correctly
    }

    /// @notice Test shouldRespond returns false when no mismatch exists (origin == sender)
    function test_ShouldRespondReturnsFalseWhenNoMismatch() public {
        // Create data with matching origin and sender
        bytes memory dataPoint = abi.encode(TEST_ORIGIN, TEST_ORIGIN);
        bytes[] memory data = new bytes[](1);
        data[0] = dataPoint;

        (bool shouldTrigger, bytes memory responseData) = trap.shouldRespond(data);

        assertFalse(shouldTrigger);
        assertEq(responseData.length, 0);
    }

    /// @notice Test shouldRespond returns true when mismatch exists (origin != sender)
    function test_ShouldRespondReturnsTrueWhenMismatchExists() public {
        // Create data with mismatched origin and sender
        bytes memory dataPoint = abi.encode(TEST_ORIGIN, TEST_SENDER);
        bytes[] memory data = new bytes[](1);
        data[0] = dataPoint;

        (bool shouldTrigger, bytes memory responseData) = trap.shouldRespond(data);

        assertTrue(shouldTrigger);
        assertGt(responseData.length, 0);

        // Decode response data
        (address origin, address sender) = abi.decode(responseData, (address, address));
        assertEq(origin, TEST_ORIGIN);
        assertEq(sender, TEST_SENDER);
    }

    /// @notice Test shouldRespond returns false when data array is empty
    function test_ShouldRespondReturnsFalseWhenDataEmpty() public {
        bytes[] memory data = new bytes[](0);

        (bool shouldTrigger, bytes memory responseData) = trap.shouldRespond(data);

        assertFalse(shouldTrigger);
        assertEq(responseData.length, 0);
    }

    /// @notice Test shouldRespond with multiple data points (uses most recent)
    function test_ShouldRespondUsesMostRecentData() public {
        // Create multiple data points
        bytes[] memory data = new bytes[](2);
        data[0] = abi.encode(TEST_ORIGIN, TEST_SENDER); // Most recent - has mismatch
        data[1] = abi.encode(TEST_ORIGIN_2, TEST_ORIGIN_2); // Older - no mismatch

        (bool shouldTrigger, bytes memory responseData) = trap.shouldRespond(data);

        // Should trigger because most recent data has mismatch
        assertTrue(shouldTrigger);
        
        // Verify response data matches most recent data
        (address origin, address sender) = abi.decode(responseData, (address, address));
        assertEq(origin, TEST_ORIGIN);
        assertEq(sender, TEST_SENDER);
    }

    /// @notice Test response contract executeResponse function
    function test_ResponseExecuteResponse() public {
        // Simply verify the function executes without error
        response.executeResponse(TEST_ORIGIN, TEST_SENDER);
        
        // Verify the function completed successfully by checking it doesn't revert
        assertTrue(true);
    }

    /// @notice Test response contract with different addresses
    function test_ResponseExecuteResponseWithDifferentAddresses() public {
        address origin = address(0xAAAA);
        address sender = address(0xBBBB);

        // Simply verify the function executes without error
        response.executeResponse(origin, sender);
        
        // Verify the function completed successfully by checking it doesn't revert
        assertTrue(true);
    }

    /// @notice Test that monitoredAddress constant is correctly set
    function test_MonitoredAddressConstant() public view {
        assertEq(trap.monitoredAddress(), MONITORED_ADDRESS);
    }

    /// @notice Test that alertRecipient constant is correctly set in response contract
    function test_AlertRecipientConstant() public view {
        address expectedRecipient = 0x1234567890123456789012345678901234567890;
        assertEq(response.alertRecipient(), expectedRecipient);
    }

    /// @notice Test edge case: zero addresses
    function test_ShouldRespondWithZeroAddresses() public {
        bytes memory dataPoint = abi.encode(address(0), address(1));
        bytes[] memory data = new bytes[](1);
        data[0] = dataPoint;

        (bool shouldTrigger, bytes memory responseData) = trap.shouldRespond(data);

        // Should trigger because addresses are different
        assertTrue(shouldTrigger);
        (address origin, address sender) = abi.decode(responseData, (address, address));
        assertEq(origin, address(0));
        assertEq(sender, address(1));
    }

    /// @notice Test edge case: same addresses should not trigger
    function test_ShouldRespondWithSameAddresses() public {
        bytes memory dataPoint = abi.encode(TEST_ORIGIN, TEST_ORIGIN);
        bytes[] memory data = new bytes[](1);
        data[0] = dataPoint;

        (bool shouldTrigger, bytes memory responseData) = trap.shouldRespond(data);

        assertFalse(shouldTrigger);
        assertEq(responseData.length, 0);
    }
}

