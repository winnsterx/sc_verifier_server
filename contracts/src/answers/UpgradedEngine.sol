pragma solidity <0.7.0;

import "openzeppelin-contracts-06/proxy/Initializable.sol";
import "openzeppelin-contracts-06/utils/Address.sol";

contract UpgradedEngine is Initializable {
    address public upgrader;
    uint256 public horsePower;

    function initialize() external initializer {
        horsePower = 1337;
        upgrader = msg.sender;
    }

    function upgrade(address newImplementation) external {
        require(msg.sender == upgrader, "Not authorized");
        // Use assembly to set the implementation slot directly
        bytes32 slot = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
        // Store the new implementation
        assembly {
            sstoreslot(slot, newImplementation)
        }
    }
} #