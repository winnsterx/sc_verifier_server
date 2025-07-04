pragma solidity ^0.6.0;
contract AttackerContract {
    address public instance;
    function setInstance(address _instance) public {
        instance = _instance;
    }

    function getBalance() public view returns (uint256) {
        return 0;
    }
}
