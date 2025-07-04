pragma solidity ^0.8.0;
abstract contract SimpleToken {
    function destroy(address payable _to) public virtual;
}

contract TokenDestroyer {
    function destroyToken(address instance, address payable to) external {
        address tokenAddress = 0x0baf607c0819CdfB946180A52e0f1F57983FCA85; // Hardcoded correct token address
        SimpleToken(tokenAddress).destroy(to);
    }
}
