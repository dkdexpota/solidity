
/**
 * This file was generated by TONDev.
 * TONDev is a part of TON OS (see http://ton.dev).
 */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
import 'MilitaryUnit.sol';
// This is class that describes you smart contract.
contract Archer is MilitaryUnit{
    constructor(AddUnit base) MilitaryUnit(base, 42, 5) public{}
}