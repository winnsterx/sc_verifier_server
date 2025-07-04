pragma solidity ^0.8.0;
contract InfiniteLoopPartner {
    receive() external payable {
        uint256 i;
        while (true) {
            i++;
            i--;
        }
    }
}
