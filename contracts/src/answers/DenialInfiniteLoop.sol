pragma solidity ^0.8.0;

contract DenialInfiniteLoop {

    receive() external payable {
        while (true) {
            // Consume all gas in an infinite loop
        }
    }

}