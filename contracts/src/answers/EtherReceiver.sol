pragma solidity ^0.8.0;

contract EtherReceiver {
    address public target;

    constructor(address _target) {
        target = _target;
    }

    function contribute() public payable {
        // Accept ETH contributions
    }

    function destroy() public {
        selfdestruct(payable(target));
    }
}