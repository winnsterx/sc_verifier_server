pragma solidity ^0.6.0;
import "../levels/Engine.sol";

contract Engine2 is Engine {
    struct AddressSlot {
        address value;
    }

    function setHorsePower(uint256 _horsePower) external {
        horsePower = _horsePower;
    }

    function setUpgrader(address _upgrader) external {
        upgrader = _upgrader;
    }
}  
