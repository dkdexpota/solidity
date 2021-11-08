pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

struct Purchase {
    uint32 id;
    string name;
    uint32 count;
    uint32 timestamp;
    bool isBought;
    uint32 cost;
}

struct PurchasesStat {
    uint32 completeCount;
    uint32 incompleteCount;
    uint32 totalCost;
}

interface IShoppingList {
    function addPurchase(string name, uint32 count) external;
    function deletePurchase(uint32 id) external;
    function buy(uint32 id, uint32 cost) external;
    function getPurchasesAndStat() external view returns(Purchase[] purchases, PurchasesStat stat);
}

interface Transactable {
    function sendTransaction(address dest, uint128 value, bool bounce, uint8 flags, TvmCell payload) external;
}

abstract contract HasConstructorWithPubKey {
    constructor(uint256 pubkey) public {}
}