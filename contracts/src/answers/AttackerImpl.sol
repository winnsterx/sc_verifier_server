pragma solidity ^0.6.12;

import "openzeppelin-contracts-06/proxy/Initializable.sol";
import "openzeppelin-contracts-06/utils/Address.sol";

contract AttackerImpl is Initializable {
    address public upgrader;
    uint256 public horsePower;

    function changeHorsePower() external {
        horsePower = 2024;
    }
}