pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;
import "./package/AShoppingListDebot.sol";
contract FillingShoppingListDebot is AShoppingListDebot {

    function _menu() internal override{
        Menu.select(
            "Shopping List",
            "--",
            [
                MenuItem("Add purchase", "", tvm.functionId(addPurchase)),
                MenuItem("Show shopping list and stat", "", tvm.functionId(showPurchases)),
                MenuItem("Delete purchase", "", tvm.functionId(deletePurchase))
            ]
        );
    }

    string name;
    function addPurchase(uint32 index) public {
        index = index;
        Terminal.input(tvm.functionId(addPurchase_), "Name purchase:", false);
    }

    function addPurchase_(string value) public {
        if (value!="") {
            name = value;
            Terminal.input(tvm.functionId(addPurchase__), "Count:", false);
        } else {
            Terminal.print(0, "Name cannot be empty.");
            _menu();
        }
    }

    function addPurchase__(string value) public {
        (uint256 count, bool status) = stoi(value);
        if (status && count != 0) {
            optional(uint256) pubkey = 0;
            LR.IShoppingList(m_address).addPurchase{
                    abiVer: 2,
                    extMsg: true,
                    sign: true,
                    pubkey: pubkey,
                    time: uint64(now),
                    expire: 0,
                    callbackId: tvm.functionId(onSuccess),
                    onErrorId: tvm.functionId(onError)
                }(name, uint32(count));
        } else {
            Terminal.print(0, "Wrong count.");
            _menu();
        }
    }

    function getDebotInfo() public functionID(0xDEB) override view returns(
        string name, string version, string publisher, string key, string author,
        address support, string hello, string language, string dabi, bytes icon
    ) {
        name = "Filling Shopping List DeBot";
        version = "0.1.0";
        publisher = "..";
        key = "..";
        author = "..";
        support = address.makeAddrStd(0, 0x5ef69d12a1eec50bb0957db712bc1ab99abd57339ff3accbfc132884c9bb3784);
        hello = "Hi, i'm a Shopping DeBot.";
        language = "en";
        dabi = m_debotAbi.get();
        icon = m_icon;
    }
}
