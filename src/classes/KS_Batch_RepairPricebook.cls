global without sharing class KS_Batch_RepairPricebook implements Database.Batchable<sObject>{
    
    global final String Query;
    global final String Entity;
    global final String Field;
    global final String Value;
    
    global KS_Batch_RepairPricebook(String q, String e, String f, String v){
        
        System.debug('-------------------------JCAR - QUERY - ' + q);
        Query=q; Entity=e; Field=f;Value=v;
    }
    
    global KS_Batch_RepairPricebook(String q){
        
        System.debug('-------------------------JCAR - QUERY - ' + q);
        Query=q;
    }    
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('-------------------------JCAR - QUERY - ' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        Map<ID,PricebookEntry> pbeMap = new Map<ID,PricebookEntry>();
        List<Product2> scopeLst = (List<Product2>)scope; 
        Set<ID> idSet = new Set<ID>(); List<ID> idLst = new List<ID>();
        for (Product2 prod : scopeLst) { pbeMap.put(prod.ID, null); }
        idSet = pbeMap.keySet(); idLst.addAll(idSet);

        List<PricebookEntry> pbeLst = [SELECT ID, Product2Id FROM PricebookEntry WHERE Product2Id IN :idLst];
        for (PricebookEntry pbe : pbeLst) { if(idSet.contains(pbe.Product2Id)) { pbeMap.remove(pbe.Product2Id); } }
        // Si el mapa aún contiene elementos, significa que estos son productos sin pricebook
        if (pbeMap.isEmpty()) {return;}
        ID pbsID = null;
        List<Pricebook2> priceBookStandard = [SELECT Id FROM Pricebook2 WHERE isStandard = true and isActive = true LIMIT 1];
        if (priceBookStandard.size()>0) {pbsID = priceBookStandard[0].ID;}
        else {return;}

        for (ID prodID : pbeMap.keySet()) {
            
            PricebookEntry pbe = new PricebookEntry();
            pbe.Pricebook2Id = pbsID;
            pbe.Product2Id = prodID;
            pbe.UnitPrice = 0;
            pbe.IsActive = true;
            pbeMap.put(prodID,pbe);
        }
        
        insert pbeMap.values();
    }
    
    global void finish(Database.BatchableContext BC){}
}