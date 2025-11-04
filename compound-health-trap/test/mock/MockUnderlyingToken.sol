// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "../../src/interfaces/IERC20.sol";

contract MockUnderlyingToken is IERC20 {
    function approve(address spender, uint256 amount) external returns (bool) {
        // For testing purposes, we don't need to do anything here.
        // We just need to check that this function is called.
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        // For testing purposes, we don't need to do anything here.
        return true;
    }

    function balanceOf(address account) external view returns (uint256) {
        return 1e18;
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        return true;
    }
}
