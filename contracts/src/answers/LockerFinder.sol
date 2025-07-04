// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IImpersonator {
    function lockers(uint256) external view returns (address);
}

contract LockerFinder {
    IImpersonator constant impersonator = IImpersonator(0xa16E02E87b7454126E5E10d957A927A7F5B5d2be);
    
    function getFirstLocker() external view returns (address) {
        return impersonator.lockers(0);
    }
}