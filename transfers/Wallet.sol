
/**
 * This file was generated by TONDev.
 * TONDev is a part of TON OS (see http://ton.dev).
 */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

contract Wallet {
    constructor() public {
        require(tvm.pubkey() != 0, 101);
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
    }

    modifier checkOwnerAndAccept {
        require(msg.pubkey() == tvm.pubkey(), 100);
		tvm.accept();
		_;
	}

    modifier send(address dest, uint128 value, bool bounce, uint16 flag) {
        dest.transfer(value, bounce, flag);
        _;
    }

    function sendWithoutFee(address dest, uint128 value, bool bounce) public pure checkOwnerAndAccept send(dest, value, bounce, 1) {}

    function sendWithFee(address dest, uint128 value, bool bounce) public pure checkOwnerAndAccept send(dest, value, bounce, 0) {}

    function sendAll(address dest, bool bounce) public pure checkOwnerAndAccept send(dest, 1, bounce, 160) {}
}