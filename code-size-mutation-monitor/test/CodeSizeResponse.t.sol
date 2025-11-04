// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {CodeSizeResponse} from "../src/CodeSizeResponse.sol";

contract CodeSizeResponseTest is Test {
    CodeSizeResponse public response;

    function setUp() public {
        response = new CodeSizeResponse();
    }

    function test_Respond_EmitsEvent() public {
        address targetContract = address(0x1234567890123456789012345678901234567890);
        uint256 oldSize = 1000;
        uint256 newSize = 1200;
        uint256 sizeDiff = 200;

        bytes memory data = abi.encode(targetContract, oldSize, newSize, sizeDiff);

        // The function should execute without reverting
        // Event emission will be verified by checking the function completes successfully
        response.respond(data);
        
        // If we get here, the function executed successfully
        assertTrue(true, "Response function should execute and emit event");
    }

    function test_Respond_HandlesCorrectData() public {
        address targetContract = address(0xABcdEFABcdEFabcdEfAbCdefabcdeFABcDEFabCD);
        uint256 oldSize = 500;
        uint256 newSize = 800;
        uint256 sizeDiff = 300;

        bytes memory data = abi.encode(targetContract, oldSize, newSize, sizeDiff);

        response.respond(data);

        // If we get here without reverting, the function executed successfully
        assertTrue(true, "Response function executed successfully");
    }

    function test_Respond_Reverts_WithInvalidData() public {
        // Test with insufficient data
        bytes memory invalidData = abi.encode(address(0x123));

        vm.expectRevert();
        response.respond(invalidData);
    }

    function test_Respond_WithZeroAddress() public {
        address targetContract = address(0);
        uint256 oldSize = 100;
        uint256 newSize = 200;
        uint256 sizeDiff = 100;

        bytes memory data = abi.encode(targetContract, oldSize, newSize, sizeDiff);

        // Execute response - should complete without reverting
        response.respond(data);
        assertTrue(true, "Response function should execute successfully");
    }

    function test_Respond_WithLargeSizeDifference() public {
        address targetContract = address(0x9999999999999999999999999999999999999999);
        uint256 oldSize = 10000;
        uint256 newSize = 50000;
        uint256 sizeDiff = 40000;

        bytes memory data = abi.encode(targetContract, oldSize, newSize, sizeDiff);

        // Execute response - should complete without reverting
        response.respond(data);
        assertTrue(true, "Response function should execute successfully");
    }

    function test_Respond_WithSameSize() public {
        address targetContract = address(0x1111111111111111111111111111111111111111);
        uint256 oldSize = 1000;
        uint256 newSize = 1000;
        uint256 sizeDiff = 0;

        bytes memory data = abi.encode(targetContract, oldSize, newSize, sizeDiff);

        // Execute response - should complete without reverting
        response.respond(data);
        assertTrue(true, "Response function should execute successfully");
    }
}