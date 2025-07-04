pragma solidity ^0.8.0;

interface IPuzzleProxy {
    function proposeNewAdmin(address _newAdmin) external;
    function approveNewAdmin(address _expectedAdmin) external;
    function upgradeTo(address _newImplementation) external;
}

interface IPuzzleWallet {
    function owner() external view returns (address);
    function init(uint _maxBalance) external;
    function addToWhitelist(address addr) external;
    function deposit() external payable;
    function execute(address to, uint256 value, bytes calldata data) external;
}

contract FixAttack {
    address instance;

    constructor(address _instance) {
        instance = _instance;
    }

    function callOwner() public view returns (address) {
        return IPuzzleWallet(instance).owner();
    }
}
