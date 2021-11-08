pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader pubkey;
import "./package/ListResources.sol" as LR;

contract ShoppingList {
    uint256 m_ownerPubkey;
    uint32 lastPurchaseId;
    mapping(uint32 => LR.Purchase) m_purchases;

    constructor(uint256 pubkey) public {
        require(pubkey != 0, 101);
        tvm.accept();
        m_ownerPubkey = pubkey;
    }

    modifier onlyOwner() {
        require(msg.pubkey() == m_ownerPubkey, 101);
        _;
    }

    function addPurchase(string name, uint32 count) public onlyOwner {
        require(count!=0);
        tvm.accept();
        lastPurchaseId++;
        m_purchases[lastPurchaseId] = LR.Purchase(lastPurchaseId, name, count, now, false, uint32(0));
    }

    function deletePurchase(uint32 id) public onlyOwner {
        require(m_purchases.exists(id), 102);
        tvm.accept();
        delete m_purchases[id];
    }

    function buy(uint32 id, uint32 cost) public onlyOwner {
        require(m_purchases.exists(id) && m_purchases[id].isBought == false, 102);
        tvm.accept();
        m_purchases[id].isBought = true;
        m_purchases[id].cost = cost;
    }

    function getPurchasesAndStat() public view returns(LR.Purchase[] purchases, LR.PurchasesStat stat) {
        uint32 count;
        bool isBought;
        uint32 cost;

        uint32 completeCount;
        uint32 incompleteCount;
        uint32 totalCost;
        
        for((uint32 id, LR.Purchase purchase) : m_purchases) {
            count = purchase.count;
            isBought = purchase.isBought;
            cost = purchase.cost;

            purchases.push(LR.Purchase(id, string(purchase.name), count, uint32(purchase.timestamp), isBought, cost));

            if (isBought) {
                completeCount+=count;
                totalCost+=(count*cost);
            } else {
                incompleteCount+=count;
            }
        }
        stat = LR.PurchasesStat(completeCount, incompleteCount, totalCost);
    }

}
