pragma solidity ^0.8.0;
interface IERC20 {
    function approve(address, uint256) external returns (bool);
}
contract WETHApprover {
    IERC20 public weth;
    address public stake;

    constructor(address payable _weth, address payable _stake) {
        weth = IERC20(_weth);
        stake = _stake;
    }

    function approve() external {
        uint256 amount = 1 ether;
        weth.approve(stake, amount);
    }
}