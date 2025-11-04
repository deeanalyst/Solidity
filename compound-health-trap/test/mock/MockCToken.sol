// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ICToken} from "../../src/interfaces/ICToken.sol";

contract MockCToken is ICToken {
    address public underlyingToken;

    constructor(address underlyingToken_) {
        underlyingToken = underlyingToken_;
    }

    function repayBorrowBehalf(address borrower, uint256 repayAmount) external returns (uint256) {
        // For testing purposes, we don't need to do anything here.
        // We just need to check that this function is called.
        return 0;
    }

    function underlying() external view returns (address) {
        return underlyingToken;
    }
}
