pragma solidity ^0.6.0;

contract Destructible {
    function selfDestruct() public {
        selfdestruct(msg.sender);
    }
}