public with sharing class KS_Product_Trigger extends KS_TriggerController {
    
    private List<ID> lstItemsID {get;set;}
    
    public KS_Product_Trigger (Boolean isAfter, Boolean isBefore, Boolean isDelete, Boolean isInsert, Boolean isUndelete, Boolean isUpdate,
        List<sObject> lstNewItems, Map<Id, sObject> mapNewItems, List<sObject> lstOldItems, Map<Id, sObject> mapOldItems)
    {
        super(isAfter, isBefore, isDelete, isInsert, isUndelete, isUpdate, lstNewItems, mapNewItems, lstOldItems, mapOldItems);
    }    
    
    public static Boolean blocked() { System.debug('-- TRIGGER BLOCKED! --'); return Test.isRunningTest() && KS_Trigger_Test.blockTrigger; }
    
    protected override void  runAfterInsert(){ if(blocked()){return;} executeAfterInsert(); }
    public void executeAfterInsert() { 
           
        List<Product2> prdLst = (List<Product2>)lstNewItems;
        lstItemsID = new List<ID>();
        lstItemsID.addAll(mapNewItems.keySet());
        
        // PRICEBOOK
        setPriceBook();
    }
    
    public void setPriceBook() {
        
        ID pbsID = null;
        List<Pricebook2> priceBookStandard = [SELECT Id FROM Pricebook2 WHERE isStandard = true and isActive = true LIMIT 1];
        if (priceBookStandard.size()>0) {pbsID = priceBookStandard[0].ID;}
        else {return;}
        
        List<PriceBookEntry> lstPBEntry = new List<PriceBookEntry>();
        for (ID itemID : lstItemsID){
            PriceBookEntry pbe = new PriceBookEntry();
            pbe.Pricebook2Id = pbsID;
            pbe.Product2Id = itemID;
            pbe.IsActive = true;
            pbe.UnitPrice = 0;
            lstPBEntry.add(pbe);
        }
        insert lstPBEntry;
    }
}