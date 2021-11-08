pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;
import "./InitializationListDebot.sol";
//Добавил еще один класс с общими функциями деботов, не относящимися к инициализации
abstract contract AShoppingListDebot is InitializationListDebot{

    function _menu() internal virtual override{}
    
    function showPurchases(uint32 index) public view {
        index = index;
        optional(uint256) none;
        LR.IShoppingList(m_address).getPurchasesAndStat{
            abiVer: 2,
            extMsg: true,
            sign: false,
            pubkey: none,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(showPurchases_),
            onErrorId: 0
        }();
    }

    function showPurchases_(LR.Purchase[] purchases, LR.PurchasesStat stat) public {
        Terminal.print(0, format("You have {}/{}/{} (bought/unbought/total cost) purchases", stat.completeCount, stat.incompleteCount, stat.totalCost));
        if (purchases.length > 0 ) {
            Terminal.print(0, "Your shopping list:");
            for(LR.Purchase purchase : purchases) {
                string bought;
                if (purchase.isBought) {
                    bought = '✓';
                } else {
                    bought = ' ';
                }
                Terminal.print(0, format("{} {}  \"{}\" count: {} cost: {} at {}", purchase.id, bought, purchase.name, purchase.count, purchase.cost, purchase.timestamp));
            }
        } else {
            Terminal.print(0, "Your shopping list is empty");
        }
        _menu();
    }

    function deletePurchase(uint32 index) public {
        index = index;
        Terminal.input(tvm.functionId(deletePurchase_), "Enter purchase id:", false);
    }

    function deletePurchase_(string value) public {
        (uint256 id_delete, bool status) = stoi(value);
        if (status && id_delete != 0) {
            optional(uint256) pubkey = 0;
            LR.IShoppingList(m_address).deletePurchase{
                    abiVer: 2,
                    extMsg: true,
                    sign: true,
                    pubkey: pubkey,
                    time: uint64(now),
                    expire: 0,
                    callbackId: tvm.functionId(onSuccess),
                    onErrorId: tvm.functionId(onError)
                }(uint32(id_delete));
        } else {
            Terminal.print(0, "Wrong id.");
            _menu();
        }
    }
}