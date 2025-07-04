pragma solidity ^0.8.0;

interface ISimpleToken {
    function destroy(address payable _to) external;
}

contract SimpleTokenInterface {
    function callDestroy(address token, address payable to) public {
        ISimpleToken(token).destroy(to);
    }
}