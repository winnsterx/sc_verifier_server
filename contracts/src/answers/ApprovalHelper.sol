// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../levels/NaughtCoin.sol";

contract ApprovalHelper {
    // Simple function to help us approve and check state
    function doApprove(NaughtCoin token, address spender, uint256 amount) external returns (bool) {
        return token.approve(spender, amount);
    }
}