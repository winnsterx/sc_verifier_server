pragma solidity ^0.6.0;
import "openzeppelin-contracts-06/proxy/Initializable.sol";
import "openzeppelin-contracts-06/utils/Address.sol";

contract EvilEngine is Initializable {
    address public upgrader;
    uint256 public horsePower;

    function initialize() external {
        horsePower = 50000;
    }
}