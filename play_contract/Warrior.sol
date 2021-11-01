
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
import 'MilitaryUnit.sol';

contract Warrior is MilitaryUnit{
    constructor(AddUnit base) MilitaryUnit(base, 1, 10) public{}
}
