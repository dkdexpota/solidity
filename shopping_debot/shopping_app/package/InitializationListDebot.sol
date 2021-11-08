pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;
import "../../libraries/Debot.sol";
import "../../libraries/Terminal.sol";
import "../../libraries/Menu.sol";
import "../../libraries/AddressInput.sol";
import "../../libraries/ConfirmInput.sol";
import "../../libraries/Upgradable.sol";
import "../../libraries/Sdk.sol";

import "../../shopping_list/package/ListResources.sol" as LR;

abstract contract InitializationListDebot is Debot, Upgradable {
    bytes m_icon;
    TvmCell m_shoppingListInit;
    uint256 m_masterPubKey;
    address m_address;
    address m_transactionAddress;

    uint32 INITIAL_BALANCE =  200000000;

    function setShoppingListCodeData(TvmCell code, TvmCell data) public {
        require(msg.pubkey() == tvm.pubkey(), 101);
        tvm.accept();
        m_shoppingListInit = tvm.buildStateInit(code, data);
    }

    function start() public override {
        Terminal.input(tvm.functionId(savePublicKey), "Please enter your public key", false);
    }

    function savePublicKey(string value) public {
        (uint res, bool status) = stoi("0x" + value);
        if (status) {
            m_masterPubKey = res;
            Terminal.print(0, "Checking if you already have a Shopping list ...");
            TvmCell deployState = tvm.insertPubkey(m_shoppingListInit, m_masterPubKey);
            m_address = address.makeAddrStd(0, tvm.hash(deployState));
            Terminal.print(0, format("Info: your shopping list address is {}", m_address));
            Sdk.getAccountType(tvm.functionId(checkStatus), m_address);
        } else {
            Terminal.input(tvm.functionId(savePublicKey), "Wrong public key. Try again!\nPlease enter your public key", false);
        }
    }

    function checkStatus(int8 acc_type) public {
        if (acc_type == 1) { // acc is active and contract is already deployed
            _menu();
        } else if (acc_type == -1)  { // acc is inactive
            Terminal.print(0, "You don't have a shopping list yet, so a new contract with an initial balance of 0.2 tokens will be deployed");
            AddressInput.get(tvm.functionId(creditAccount), "Select a wallet for payment. We will ask you to sign two transactions");
        } else  if (acc_type == 0) { // acc is uninitialized
            Terminal.print(0, format(
                "Deploying new contract. If an error occurs, check if your shopping contract has enough tokens on its balance"
            ));
            deploy();
        } else if (acc_type == 2) {  // acc is frozen
            Terminal.print(0, format("Can not continue: account {} is frozen", m_address));
        }
    }

    function creditAccount(address value) public {
        m_transactionAddress = value;
        optional(uint256) pubkey = 0;
        TvmCell empty;
        LR.Transactable(m_transactionAddress).sendTransaction{
            abiVer: 2,
            extMsg: true,
            sign: true,
            pubkey: pubkey,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(waitBeforeDeploy),
            onErrorId: tvm.functionId(onErrorRepeatCredit)
        }(m_address, INITIAL_BALANCE, false, 3, empty);
    }

    function onErrorRepeatCredit(uint32 sdkError, uint32 exitCode) public {
        Terminal.print(0, format("Operation failed. sdkError {}, exitCode {}", sdkError, exitCode));
        creditAccount(m_transactionAddress);
    }

    function waitBeforeDeploy() public  {
        Sdk.getAccountType(tvm.functionId(checkIfContractDeployed), m_address);
    }

    function checkIfContractDeployed(int8 acc_type) public {
        if (acc_type ==  0) {
            deploy();
        } else {
            waitBeforeDeploy();
        }
    }

    function deploy() private view {
        TvmCell image = tvm.insertPubkey(m_shoppingListInit, m_masterPubKey);
        optional(uint256) none;
        TvmCell deployMsg = tvm.buildExtMsg({
            abiVer: 2,
            dest: m_address,
            callbackId: tvm.functionId(onSuccess),
            onErrorId:  tvm.functionId(onErrorRepeatDeploy),    // Just repeat if something went wrong
            time: 0,
            expire: 0,
            sign: true,
            pubkey: none,
            stateInit: image,
            call: {LR.HasConstructorWithPubKey, m_masterPubKey}
        });
        tvm.sendrawmsg(deployMsg, 1);
    }

    function onErrorRepeatDeploy(uint32 sdkError, uint32 exitCode) public {
        Terminal.print(0, format("Operation failed. sdkError {}, exitCode {}", sdkError, exitCode));
        deploy();
    }

    function onError(uint32 sdkError, uint32 exitCode) public {
        Terminal.print(0, format("Operation failed. sdkError {}, exitCode {}", sdkError, exitCode));
        _menu();
    }

    function onSuccess() public{
        _menu();
    }

    function _menu() internal virtual {}

    function onCodeUpgrade() internal override {
        tvm.resetStorage();
    }
       
    function getRequiredInterfaces() public view override returns (uint256[] interfaces) {
        return [Terminal.ID, Menu.ID, AddressInput.ID, ConfirmInput.ID];
    }
}   
