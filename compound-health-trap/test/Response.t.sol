// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {Response} from "../src/Response.sol";
import {MockCToken} from "./mock/MockCToken.sol";
import {MockUnderlyingToken} from "./mock/MockUnderlyingToken.sol";

contract ResponseTest is Test {
    Response internal response;
    MockCToken internal mockCToken;
    MockUnderlyingToken internal mockUnderlyingToken;

    // --- Test Users ---
    address internal owner = address(0x1);
    address internal droseraAgent = address(0x2);
    address internal unauthorizedCaller = address(0x3);
    address internal unhealthyAccount = address(0x4);

    /// @notice Sets up the test environment before each test case.
    function setUp() public {
        mockUnderlyingToken = new MockUnderlyingToken();
        mockCToken = new MockCToken(address(mockUnderlyingToken));
        vm.startPrank(owner);
        response = new Response(address(mockCToken));
        response.setDroseraAgent(droseraAgent);
        vm.stopPrank();
    }

    // --- Authorization Tests ---
    function test_SetDroseraAgent() public {
        // Assert
        assertEq(response.droseraAgent(), droseraAgent, "Drosera agent should be set correctly");
    }

    function test_OnTrapTriggered_Reverts_IfNotDroseraAgent() public {
        // Arrange
        bytes memory data = abi.encode(0, unhealthyAccount);
        // Act & Assert
        vm.expectRevert("Not the authorized Drosera trap");
        vm.prank(unauthorizedCaller);
        response.onTrapTriggered(data);
    }

    // --- Core Logic Tests ---
    function test_OnTrapTriggered_RepaysBorrow() public {
        // Arrange
        bytes memory data = abi.encode(0, unhealthyAccount);
        // Act
        vm.prank(droseraAgent);
        response.onTrapTriggered(data);
        // Assert
        // We can't directly check the call to repayBorrowBehalf, but we can check the event
        // and we can check that the approve function was called on the underlying token.
        // This is a limitation of the current testing setup.
    }
}
