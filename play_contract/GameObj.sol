/**
 * This file was generated by TONDev.
 * TONDev is a part of TON OS (see http://ton.dev).
 */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
import 'GameObjInterface.sol';
// This is class that describes you smart contract.
contract GameObj is GameObjInterface{
    uint8 defencePoins;
    address baseAddress;

    function getDefencePoins() public view returns(uint8) {
        return defencePoins;
    }

    function isDead() public returns(bool){
        if (defencePoins == 0){
            return true;
        } else {
            return false;
        }
    }

    function death(address dest) virtual public {}

    function acceptAttack(uint8 power, address dest) public override {
        tvm.accept();
        if (defencePoins<=power) {
            defencePoins = 0;
            death(dest);
        } else {
            defencePoins-=power;
        }
    }

    modifier onlyOwnerOrFighter {
		require(defencePoins == 0 || address(msg.pubkey()) == baseAddress);
		_;
	}

    function sendAll(address dest) public pure {
        tvm.accept();
        dest.transfer(1, false, 160);
    }
}