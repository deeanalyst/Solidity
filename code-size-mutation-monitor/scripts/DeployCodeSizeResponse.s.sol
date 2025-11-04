// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {CodeSizeResponse} from "../src/CodeSizeResponse.sol";

/// @notice Deployment script for CodeSizeResponse contract
/// @dev Deploy this contract using Foundry: forge script script/DeployCodeSizeResponse.s.sol:DeployCodeSizeResponse --rpc-url hoodi --broadcast --verify
contract DeployCodeSizeResponse is Script {
    function run() external returns (address) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        CodeSizeResponse response = new CodeSizeResponse();

        console.log("CodeSizeResponse deployed at:", address(response));

        vm.stopBroadcast();
        return address(response);
    }
}
