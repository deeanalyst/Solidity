// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface ICToken {
    function repayBorrowBehalf(address borrower, uint256 repayAmount)
        external
        returns (uint256);

    function underlying() external view returns (address);
}
