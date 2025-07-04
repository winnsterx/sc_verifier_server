pragma solidity ^0.8.0;
import "openzeppelin-contracts-08/access/Ownable.sol";

contract AttackerDexTwo is Ownable {
    address public token1;
    address public token2;

    constructor() {}


    function setTokens(address _token1, address _token2) public onlyOwner {
        token1 = _token1;
        token2 = _token2;
    }

    function add_liquidity(address token_address, uint256 amount) public onlyOwner {
        // Assuming this is not part of the level's logic but for testing, this is stub
    }

    function swap(address from, address to, uint256 amount) public {
        // Stub
    }

    function getSwapAmount(address from, address to, uint256 amount) public view returns (uint256) {
        // Stub
    }

    function approve(address spender, uint256 amount) public {
        // Not needed
    }

    function balanceOf(address token, address account) public view returns (uint256) {
        // Stub
    }

} // Dummy for action