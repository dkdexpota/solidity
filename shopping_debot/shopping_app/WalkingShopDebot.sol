pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;
import "./package/AShoppingListDebot.sol";
contract WalkingShopDebot is AShoppingListDebot {

    function _menu() internal override{
        Menu.select(
            "Shopping List",
            "--",
            [
                MenuItem("Buy purchase", "", tvm.functionId(buyPurchase)),
                MenuItem("Show shopping list and stat", "", tvm.functionId(showPurchases)),
                MenuItem("Delete purchase", "", tvm.functionId(deletePurchase))
            ]
        );
    }

    uint32 id_buy;
    function buyPurchase(uint32 index) public {
        index = index;
        Terminal.input(tvm.functionId(buyPurchase_), "Enter purchase id:", false);
    }

    function buyPurchase_(string value) public {
        (uint256 id, bool status) = stoi(value);
        if (status && id != 0) {
            id_buy = uint32(id);
            Terminal.input(tvm.functionId(buyPurchase__), "Cost:", false);
        } else {
            Terminal.print(0, "Wrong id.");
            _menu();
        }
    }

    function buyPurchase__(string value) public {
        (uint256 cost, bool status) = stoi(value);
        if (status && cost != 0) {
            optional(uint256) pubkey = 0;
            LR.IShoppingList(m_address).buy{
                    abiVer: 2,
                    extMsg: true,
                    sign: true,
                    pubkey: pubkey,
                    time: uint64(now),
                    expire: 0,
                    callbackId: tvm.functionId(onSuccess),
                    onErrorId: tvm.functionId(onError)
                }(id_buy, uint32(cost));
        } else {
            Terminal.print(0, "Wrong cost.");
            _menu();
        }
    }

    function getDebotInfo() public functionID(0xDEB) override view returns(
        string name, string version, string publisher, string key, string author,
        address support, string hello, string language, string dabi, bytes icon
    ) {
        name = "Walking around the shop DeBot";
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
