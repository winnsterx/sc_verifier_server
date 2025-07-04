pragma solidity ^0.8.0;

contract RevertReceiver {
    receive() external payable {
        revert("Denial");
    }
}
