// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleTest {
    address public naughtCoin;
    
    constructor(address _naughtCoin) {
        naughtCoin = _naughtCoin;
    }
    
    function checkBalance(address account) public view returns (uint256) {
        (bool success, bytes memory data) = naughtCoin.staticcall(
            abi.encodeWithSignature("balanceOf(address)", account)
        );
        require(success, "Call failed");
        return abi.decode(data, (uint256));
    }
    
    function getPlayer() public view returns (address) {
        (bool success, bytes memory data) = naughtCoin.staticcall(
            abi.encodeWithSignature("player()")
        );
        require(success, "Call failed");
        return abi.decode(data, (address));
    }
}