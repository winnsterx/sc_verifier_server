pragma solidity <0.7.0;

import "openzeppelin-contracts-06/utils/Address.sol";
import "openzeppelin-contracts-06/proxy/Initializable.sol";

contract EngineUpgraded is Initializable {
    address public upgrader;
    uint256 public horsePower = 9999;

    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    function initialize() external initializer {
        horsePower = 9999;
        upgrader = msg.sender;
    }

    function changeHorsePower(uint256 _newPower) public {
        horsePower = _newPower;
    }
}