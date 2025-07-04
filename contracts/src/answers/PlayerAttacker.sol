pragma solidity ^0.8.0;
import "../levels/MagicNum.sol";

contract PlayerAttacker {
    address public player = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    function setPlayerSol(address magicNum) public {
        MagicNum(magicNum).setSolver(player);
    }
}
