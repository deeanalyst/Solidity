// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/TokenPairPriceDivergenceResponse.sol";

/// @notice Deployment script for TokenPairPriceDivergenceResponse contract
/// @dev Deploy using: forge script scripts/DeployTokenPairPriceDivergenceResponse.s.sol:DeployTokenPairPriceDivergenceResponse --rpc-url <rpc-url> --broadcast --verify
contract DeployTokenPairPriceDivergenceResponse is Script {
    function run() external {
        vm.startBroadcast();
        
        // Deploy response contract (no constructor args needed)
        TokenPairPriceDivergenceResponse response = new TokenPairPriceDivergenceResponse();
        
        console.log("TokenPairPriceDivergenceResponse deployed at:", address(response));
        
        vm.stopBroadcast();
    }
}

