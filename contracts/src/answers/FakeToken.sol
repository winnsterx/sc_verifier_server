pragma solidity ^0.8.0;
import "openzeppelin-contracts-08/token/ERC20/ERC20.sol";

contract FakeToken is ERC20 {
    constructor() ERC20("FakeToken", "FTK") {
        _mint(msg.sender, 1000 ether);  // Mint a large amount to exploit with
    }
}