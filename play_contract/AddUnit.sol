pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

// This is class that describes you smart contract.
interface AddUnit {
    function addUnit(address unit) external;
    function removeUnit(address unit) external;
}