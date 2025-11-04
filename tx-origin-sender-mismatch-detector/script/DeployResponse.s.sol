// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {TxOriginMismatchResponse} from "../src/TxOriginMismatchResponse.sol";

/// @title DeployResponse
/// @notice Script to deploy the TxOriginMismatchResponse contract
/// @dev This contract is deployed via Foundry and should be called by Drosera when a mismatch is detected
contract DeployResponse is Script {
    function run() external returns (TxOriginMismatchResponse) {
        vm.startBroadcast();

        TxOriginMismatchResponse response = new TxOriginMismatchResponse();

        vm.stopBroadcast();

        return response;
    }
}

