pragma solidity ^0.8.0;

abstract contract PuzzleProxyAttacker {
    address public admin;

    function proposeNewAdmin(address _newAdmin) external {
        admin = _newAdmin;
    }

    function approveNewAdmin(address _expectedAdmin) external {
        require(admin != address(0), "Admin not proposed");
        // Mimic proxy approval logic
    }
}