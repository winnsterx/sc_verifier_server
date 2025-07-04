pragma solidity ^0.8.0;

interface IForta {
    function setDetectionBot(address detectionBotAddress) external;
}

contract FortaInterface {
    IForta public forta = IForta(0x5FbDB2315678afecb367f032d93F642f64180aa3);

    function setDetectionBot(address detectionBotAddress) external {
        forta.setDetectionBot(detectionBotAddress);
    }
}