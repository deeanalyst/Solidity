// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {TxOriginMismatchTrap} from "../src/TxOriginMismatchTrap.sol";

/// @title MockProxyContract
/// @notice Mock contract that acts as a proxy to demonstrate tx.origin != msg.sender scenario
/// @dev This contract forwards calls to the trap, creating a scenario where tx.origin != msg.sender
contract MockProxyContract {
    TxOriginMismatchTrap public trap;

    constructor(address _trap) {
        trap = TxOriginMismatchTrap(_trap);
    }

    /// @notice Forward collect call to trap, creating a proxy scenario
    function forwardCollect() external view returns (bytes memory) {
        // When called through this proxy, tx.origin will be the original caller
        // but msg.sender will be this contract's address
        return trap.collect();
    }

    /// @notice Direct call to trap's collect function
    function directCollect() external view returns (bytes memory) {
        return trap.collect();
    }
}

