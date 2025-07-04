pragma solidity ^0.6.0;

import "openzeppelin-contracts-06/proxy/Initializable.sol";

contract AttackerImplementation is Initializable {
    address public upgrader;
    uint256 public horsePower;

    function initialize() public initializer {
        upgrader = msg.sender;
        horsePower = 0;
    }
}
