pragma solidity ^0.8.0;
contract AttackerBuilding {
    bool private flipped = false;

    function isLastFloor(uint256) public returns (bool) {
        if (flipped) {
            return true;
        }
        flipped = true;
        return false;
    }
}
