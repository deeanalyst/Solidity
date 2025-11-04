// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IComptroller {
    function getAccountLiquidity(address account)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );
}
