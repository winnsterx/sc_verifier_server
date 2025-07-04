pragma solidity ^0.8.0;

import "openzeppelin-contracts-08/token/ERC20/ERC20.sol";

contract MaliciousToken is ERC20 {
    constructor() ERC20("Malicious", "MAL") {
        _mint(msg.sender, 1000000);
    }
}