// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { ICToken } from "./interfaces/ICToken.sol";
import { IERC20 } from "./interfaces/IERC20.sol";

/// @title Response
/// @notice A simple response contract that repays a borrow on behalf of an unhealthy account.
contract Response {
    event Repaid(address indexed borrower, uint256 amount);

    ICToken public immutable cToken;
    address public owner;
    address public droseraAgent; // This should be the address of the deployed trap

    constructor(address cToken_) {
        cToken = ICToken(cToken_);
        owner = msg.sender;
    }

    /// @notice Sets the authorized trap address that can trigger a response.
    function setDroseraAgent(address droseraAgent_) external {
        require(msg.sender == owner, "Not owner");
        droseraAgent = droseraAgent_;
    }

    /// @notice This function is called by the Drosera network when the trap's
    ///         `shouldRespond` function returns true.
    /// @param data The encoded liquidity and address of the unhealthy account.
    function onTrapTriggered(bytes calldata data) external {
        // Although Drosera calls this, we can add a check to ensure
        // it's for the trap we expect, preventing cross-trap trigger exploits.
        require(msg.sender == droseraAgent, "Not the authorized Drosera trap");

        ( , address unhealthyAccount) = abi.decode(
            data,
            (uint256, address)
        );

        // Cure the liquidity shortfall by repaying some of the borrow.
        uint256 repayAmount = 1e18; // Repay 1 underlying token
        IERC20(ICToken(cToken).underlying()).approve(address(cToken), repayAmount);
        cToken.repayBorrowBehalf(unhealthyAccount, repayAmount);

        emit Repaid(unhealthyAccount, repayAmount);
    }
}
