// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IComptroller} from "../../src/interfaces/IComptroller.sol";

contract MockComptroller is IComptroller {
    uint256 internal mockLiquidity;

    function getAccountLiquidity(address account)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        return (0, mockLiquidity, 0);
    }

    function setMockLiquidity(uint256 liquidity) external {
        mockLiquidity = liquidity;
    }
}
