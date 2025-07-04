pragma solidity ^0.8.0;

contract DirectDestroyer {

    function destroyToken(address tokenAddress) public {
        (bool success, ) = tokenAddress.call(abi.encodeWithSignature("destroy(address)", msg.sender));
        require(success);
    }
}
