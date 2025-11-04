// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {CodeSizeMonitorTrap} from "../src/CodeSizeMonitorTrap.sol";
import {MockTargetContract, MockTargetContractLarge} from "../src/mocks/MockTargetContract.sol";

contract CodeSizeMonitorTrapTest is Test {
    CodeSizeMonitorTrap public trap;
    MockTargetContract public smallContract;
    MockTargetContractLarge public largeContract;

    address constant PLACEHOLDER_TARGET = 0x1234567890123456789012345678901234567890;

    function setUp() public {
        // Deploy the trap contract (it will use the hardcoded placeholder address)
        trap = new CodeSizeMonitorTrap();
        
        // Deploy mock contracts for testing
        smallContract = new MockTargetContract();
        largeContract = new MockTargetContractLarge();
    }

    function test_Collect_ReturnsCorrectData() public view {
        // This test checks the collect function structure
        // Note: The trap uses a hardcoded address, so we test with the placeholder
        bytes memory data = trap.collect();
        
        // Decode and verify the structure
        (address target, uint256 codeSize) = abi.decode(data, (address, uint256));
        
        assertEq(target, PLACEHOLDER_TARGET, "Target address should match placeholder");
        // Code size should be 0 for the placeholder address (doesn't exist)
        assertEq(codeSize, 0, "Placeholder address should have zero code size");
    }

    function test_ShouldRespond_ReturnsFalse_WhenDataLengthLessThanTwo() public {
        CodeSizeMonitorTrap trapInstance = new CodeSizeMonitorTrap();
        
        bytes[] memory data = new bytes[](1);
        data[0] = abi.encode(PLACEHOLDER_TARGET, uint256(100));
        
        (bool shouldRespond, bytes memory responseData) = trapInstance.shouldRespond(data);
        
        assertFalse(shouldRespond, "Should not respond with only one data point");
        assertEq(responseData.length, 0, "Response data should be empty");
    }

    function test_ShouldRespond_ReturnsFalse_WhenSizeChangeBelowThreshold() public {
        CodeSizeMonitorTrap trapInstance = new CodeSizeMonitorTrap();
        
        bytes[] memory data = new bytes[](2);
        data[0] = abi.encode(PLACEHOLDER_TARGET, uint256(100));
        data[1] = abi.encode(PLACEHOLDER_TARGET, uint256(150)); // 50 bytes difference < 100 threshold
        
        (bool shouldRespond, bytes memory responseData) = trapInstance.shouldRespond(data);
        
        assertFalse(shouldRespond, "Should not respond when change is below threshold");
        assertEq(responseData.length, 0, "Response data should be empty");
    }

    function test_ShouldRespond_ReturnsTrue_WhenSizeChangeExceedsThreshold() public {
        CodeSizeMonitorTrap trapInstance = new CodeSizeMonitorTrap();
        
        bytes[] memory data = new bytes[](2);
        uint256 oldSize = 100;
        uint256 newSize = 250; // 150 bytes difference > 100 threshold
        data[0] = abi.encode(PLACEHOLDER_TARGET, oldSize);
        data[1] = abi.encode(PLACEHOLDER_TARGET, newSize);
        
        (bool shouldRespond, bytes memory responseData) = trapInstance.shouldRespond(data);
        
        assertTrue(shouldRespond, "Should respond when change exceeds threshold");
        assertGt(responseData.length, 0, "Response data should not be empty");
        
        // Decode response data
        (address target, uint256 decodedOldSize, uint256 decodedNewSize, uint256 sizeDiff) = 
            abi.decode(responseData, (address, uint256, uint256, uint256));
        
        assertEq(target, PLACEHOLDER_TARGET, "Target should match");
        assertEq(decodedOldSize, oldSize, "Old size should match");
        assertEq(decodedNewSize, newSize, "New size should match");
        assertEq(sizeDiff, 150, "Size difference should be 150");
    }

    function test_ShouldRespond_HandlesSizeDecrease() public {
        CodeSizeMonitorTrap trapInstance = new CodeSizeMonitorTrap();
        
        bytes[] memory data = new bytes[](2);
        uint256 oldSize = 300;
        uint256 newSize = 150; // 150 bytes decrease > 100 threshold
        data[0] = abi.encode(PLACEHOLDER_TARGET, oldSize);
        data[1] = abi.encode(PLACEHOLDER_TARGET, newSize);
        
        (bool shouldRespond, bytes memory responseData) = trapInstance.shouldRespond(data);
        
        assertTrue(shouldRespond, "Should respond when size decreases beyond threshold");
        
        (,,, uint256 sizeDiff) = abi.decode(responseData, (address, uint256, uint256, uint256));
        assertEq(sizeDiff, 150, "Size difference should be 150 (absolute value)");
    }

    function test_ShouldRespond_Reverts_WhenTargetAddressMismatch() public {
        CodeSizeMonitorTrap trapInstance = new CodeSizeMonitorTrap();
        
        bytes[] memory data = new bytes[](2);
        address wrongAddress = address(0x9999999999999999999999999999999999999999);
        data[0] = abi.encode(wrongAddress, uint256(100));
        data[1] = abi.encode(PLACEHOLDER_TARGET, uint256(250));
        
        // Should revert with "Invalid target address"
        vm.expectRevert("Invalid target address");
        trapInstance.shouldRespond(data);
    }

    function test_Constants_AreCorrectlySet() public view {
        assertEq(trap.TARGET_CONTRACT(), PLACEHOLDER_TARGET, "Target contract should match placeholder");
        assertEq(trap.SIZE_THRESHOLD(), 100, "Size threshold should be 100 bytes");
    }

    function test_CodeSize_OfDeployedContracts() public view {
        // Test that we can get code sizes of deployed contracts
        uint256 smallSize = getCodeSize(address(smallContract));
        uint256 largeSize = getCodeSize(address(largeContract));
        
        console.log("Small contract code size:", smallSize);
        console.log("Large contract code size:", largeSize);
        
        // Both should have code
        assertGt(smallSize, 0, "Small contract should have code");
        assertGt(largeSize, 0, "Large contract should have code");
        
        // Large contract should have more code
        assertGt(largeSize, smallSize, "Large contract should have more code than small");
    }

    function test_Integration_WithRealContractAddresses() public {
        // This test simulates monitoring a real contract by temporarily modifying behavior
        // In practice, you would deploy the trap with the actual target address hardcoded
        
        // Get code sizes of our mock contracts
        uint256 smallSize = getCodeSize(address(smallContract));
        uint256 largeSize = getCodeSize(address(largeContract));
        
        // Calculate difference
        uint256 sizeDiff = largeSize > smallSize ? largeSize - smallSize : smallSize - largeSize;
        
        // If the difference is significant, create a scenario
        if (sizeDiff > 100) {
            bytes[] memory data = new bytes[](2);
            data[0] = abi.encode(PLACEHOLDER_TARGET, smallSize);
            data[1] = abi.encode(PLACEHOLDER_TARGET, largeSize);
            
            (bool shouldRespond,) = trap.shouldRespond(data);
            
            // Should respond if difference exceeds threshold
            assertTrue(shouldRespond, "Should respond when real contract sizes differ significantly");
        }
    }

    // Helper function to get code size
    function getCodeSize(address _addr) internal view returns (uint256) {
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        return size;
    }
}
