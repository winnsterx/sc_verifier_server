pragma solidity ^0.8.0;

contract DataEncoder {
    function getDepositData() public pure returns (bytes memory) {
        return abi.encodeWithSignature("deposit()");
    }
    
    function getMulticallWithDeposit() public pure returns (bytes memory) {
        bytes[] memory data = new bytes[](1);
        data[0] = abi.encodeWithSignature("deposit()");
        return abi.encodeWithSignature("multicall(bytes[])", data);
    }
}