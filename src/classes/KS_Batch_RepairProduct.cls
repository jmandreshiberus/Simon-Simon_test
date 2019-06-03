global without sharing class KS_Batch_RepairProduct implements Database.Batchable<sObject>{
    
    global final String Query;
    global final String Entity;
    global final String Field;
    global final String Value;
    
    global KS_Batch_RepairProduct(String q, String e, String f, String v){
        
        System.debug('-------------------------JCAR - QUERY - ' + q);
        Query=q; Entity=e; Field=f;Value=v;
    }
    
    global KS_Batch_RepairProduct(String q){
        
        System.debug('-------------------------JCAR - QUERY - ' + q);
        Query=q;
    }    
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('-------------------------JCAR - QUERY - ' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        System.debug('-- JCAR -- --------------------- scope - ' + scope.size() + ' - ' + scope);
        Boolean deepDebug = scope.size()==1;
        System.debug('-- JCAR -- --------------------- deepDebug? ' + (deepDebug ? 'SI' : 'NO') );
        
        Map<ID,Product2> prodMap = new Map<ID,Product2>();
        Map<ID,PricebookEntry> pbeMap = new Map<ID,PricebookEntry>();
        List<Product2> scopeLst = (List<Product2>)scope; 
        Set<ID> idSet = new Set<ID>(); List<ID> idLst = new List<ID>();
        for (Product2 prod : scopeLst) { pbeMap.put(prod.ID, null); prodMap.put(prod.ID, prod); }
        idSet = pbeMap.keySet(); idLst.addAll(idSet);

        List<PricebookEntry> pbeLst = [SELECT ID, Product2Id FROM PricebookEntry WHERE Product2Id IN :idLst];
        for (PricebookEntry pbe : pbeLst) { if(idSet.contains(pbe.Product2Id)) { pbeMap.remove(pbe.Product2Id); } }
        // Si el mapa aún contiene elementos, significa que estos son productos sin pricebook
        //if (pbeMap.isEmpty()) {return;}
        ID pbsID = null;
        List<Pricebook2> priceBookStandard = [SELECT Id FROM Pricebook2 WHERE isStandard = true and isActive = true LIMIT 1];
        if (priceBookStandard.size()>0) {pbsID = priceBookStandard[0].ID;}
        //else {return;}

        for (ID prodID : pbeMap.keySet()) {
            
            PricebookEntry pbe = new PricebookEntry();
            pbe.Pricebook2Id = pbsID;
            pbe.Product2Id = prodID;
            pbe.UnitPrice = 0;
            pbe.IsActive = true;
            pbe.CurrencyIsoCode = 'EUR';
            pbeMap.put(prodID,pbe);
        }

        System.debug('-- JCAR -- --------------------- PricebookEntry - ' + pbeMap.size() + ' - ' + pbeMap);
        insert pbeMap.values();
        
        Map<String, KS_Organizacion_Producto__c> goodOrgMap = new Map<String, KS_Organizacion_Producto__c>();
        Map<ID, KS_Organizacion_Producto__c> deleteORG = new Map<ID, KS_Organizacion_Producto__c>();
        
        Map<ID, Map<String, KS_Organizacion_Producto__c>> orgMap = new Map<ID, Map<String, KS_Organizacion_Producto__c>>();
        List<KS_Organizacion_Producto__c> orgQRY = 
            [SELECT ID, KS_Producto__c, KS_Producto_SAP__c, 
             KS_ID_Organizacion_Producto__c,
             KS_Organizacion_de_Ventas__c, KS_Canal_de_distribucion__c, KS_Sector__c,
             KS_Superfamilia__c, KS_Familia__c, KS_Serie_Gama__c, KS_Subserie__c, 
             CreatedDate
             FROM KS_Organizacion_Producto__c 
             WHERE KS_Producto__c IN :idLst];
        System.debug('-- JCAR -- --------------------- KS_Organizacion_Producto__c - ' + orgQRY.size() + ' - ' + orgQRY);
        
        for (KS_Organizacion_Producto__c org : orgQRY) {
            org = buildOrgProdID(org);
            
            if (deepDebug) { System.debug('-- JCAR -- --------------------- ' + org.KS_Producto_SAP__c + ' - ' + org); }
            
            Map<String, KS_Organizacion_Producto__c> prodOrgMap = new Map<String, KS_Organizacion_Producto__c>();
            if (orgMap.containsKey(org.KS_Producto__c)) { prodOrgMap = orgMap.get(org.KS_Producto__c); }
            KS_Organizacion_Producto__c goodOrg = new KS_Organizacion_Producto__c();
            if (deepDebug) { System.debug('-- JCAR -- --------------------- prodOrgMap - ' + prodOrgMap.size() + ' - ' + prodOrgMap); }
            
            if (prodOrgMap.containsKey(org.KS_ID_Organizacion_Producto__c)) {
                goodOrg = prodOrgMap.get(org.KS_ID_Organizacion_Producto__c); 
                
                if (org.CreatedDate > goodOrg.CreatedDate || goodOrg.ID == null) { // Esto solamente pasará si encuentra otra org con misma ID
                    if (org.KS_Superfamilia__c == null) { org.KS_Superfamilia__c = goodOrg.KS_Superfamilia__c; }
                    if (org.KS_Familia__c == null) { org.KS_Familia__c = goodOrg.KS_Familia__c; }
                    if (org.KS_Serie_Gama__c == null) { org.KS_Serie_Gama__c = goodOrg.KS_Serie_Gama__c; }
                    if (org.KS_Subserie__c == null) { org.KS_Subserie__c = goodOrg.KS_Subserie__c; }
                    
                    if (goodOrg.ID != null) { deleteORG.put(goodOrg.ID, goodOrg); }
                    if (deepDebug) { System.debug('-- JCAR -- --------------------- CHANGE ' + org.KS_ID_Organizacion_Producto__c
                                                  + ' - ' + goodOrg.ID + ' to ' + org.ID); }
                    goodOrg = org;
                    
                } else { if (org.ID != null) { deleteORG.put(org.ID, org); } }
            
            } else { goodOrg = org; }

            if (goodOrg.ID != null) { goodOrgMap.put(org.KS_ID_Organizacion_Producto__c, goodOrg); }
            prodOrgMap.put(org.KS_ID_Organizacion_Producto__c, goodOrg);
            orgMap.put(org.KS_Producto__c, prodOrgMap);
        }
        
        if (deepDebug) { System.debug('-- JCAR -- --------------------- orgMap - ' + orgMap.size() + ' - ' + orgMap); }
        
        if (deepDebug) { System.debug('-- JCAR -- --------------------- deleteORG - ' + deleteORG.size() + ' - ' + deleteORG); }
        if (deepDebug) { System.debug('-- JCAR -- --------------------- goodOrgMap - ' + goodOrgMap.size() + ' - ' + goodOrgMap); }
        
        delete deleteORG.values();
        update goodOrgMap.values();
        
        for (String prodID : orgMap.keySet()) {
            Product2 prod = prodMap.get(prodID);
            prod.KS_OP_Simon_Nacional__c = 0; prod.KS_OP_Simon_Exportacion__c = 0;
            prod.KS_OP_Fluvia_Nacional__c = 0; prod.KS_OP_Fluvia_Exportacion__c = 0;
            for (String marca : orgMap.get(prodID).keySet()) {
                if (marca.contains('-SI1010')) { prod.KS_OP_Simon_Nacional__c = 1; }
                if (marca.contains('-SI1020')) { prod.KS_OP_Simon_Exportacion__c = 1; }
                if (marca.contains('-FL3110')) { prod.KS_OP_Fluvia_Nacional__c = 1; }
                if (marca.contains('-FL3120')) { prod.KS_OP_Fluvia_Exportacion__c = 1; }
            }
            prodMap.put(prod.ID, prod);
        }
        
        update prodMap.values();
    }
    
    global void finish(Database.BatchableContext BC){}
    
    private KS_Organizacion_Producto__c buildOrgProdID(KS_Organizacion_Producto__c org) {
        
        System.debug('-- JCAR -- --------------------- buildOrgProdID - ' + org.KS_ID_Organizacion_Producto__c);
        org.KS_ID_Organizacion_Producto__c = org.KS_Producto_SAP__c + '-';
        org.KS_ID_Organizacion_Producto__c += org.KS_Organizacion_de_Ventas__c != null ? org.KS_Organizacion_de_Ventas__c : '';
        org.KS_ID_Organizacion_Producto__c += org.KS_Canal_de_distribucion__c != null ? org.KS_Canal_de_distribucion__c : '';
        org.KS_ID_Organizacion_Producto__c += org.KS_Sector__c != null ? org.KS_Sector__c : '';
        System.debug('-- JCAR -- --------------------- buildOrgProdID - ' + org.KS_ID_Organizacion_Producto__c);
        
        return org;
    }
}