global without sharing class KS_Batch_Cuentas implements Database.Batchable<sObject>{
    
    global final String Query;
    global final String Entity;
    global final String Field;
    global final String Value;
    
    global KS_Batch_Cuentas(String q, String e, String f, String v){
        
        System.debug('-------------------------JCAR - QUERY - ' + q);
        Query=q; Entity=e; Field=f;Value=v;
    }
    
    global KS_Batch_Cuentas(String q){
        
        System.debug('-------------------------JCAR - QUERY - ' + q);
        Query=q;
    }    
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('-------------------------JCAR - QUERY - ' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        System.debug('-------------------------JCAR - SCOPE - ' + SCOPE.size());
		
        System.debug('-------------------------JCAR - userProfile - ' + getProfile());
        
        Map<ID, Account> accMap = new Map<ID, Account>();
        List<ID> sobjIDLst = new List<ID>();
        for (sObject sobj : scope) {
            sobjIDLst.add(sobj.ID);
        }
        
        // Mapeo eventos
        
        Datetime dt = Datetime.now().addMonths(-12);
        
        Map<ID, Set<ID>> eventosAcc = new Map<ID, Set<ID>>();
        List<Event> evLst = [SELECT ID, WhatId FROM Event WHERE WhatId IN :sobjIDLst AND CreatedDate >= :dt];
        for (Event ev : evLst) {
            
            Set<ID> evCnt = new Set<ID>();
            if ( eventosAcc.containsKey(ev.WhatId) ) 
            { evCnt = eventosAcc.get(ev.WhatId); }
            evCnt.add(ev.ID); eventosAcc.put(ev.WhatId, evCnt);
        }
        System.debug('-------------------------JCAR - ACCOUNT EVENTOS - ' + eventosAcc.size() + ' - ' + eventosAcc);
        
        // Mapeo ofertas
        
        Map<ID, Set<ID>> ofertasAcc = new Map<ID, Set<ID>>();
        List<Opportunity> oppLst = [SELECT ID, KS_Distribuidor__c FROM Opportunity WHERE KS_Distribuidor__c IN :sobjIDLst];
        for (Opportunity opp : oppLst) {
            
            Set<ID> oppCnt = new Set<ID>();
            if ( ofertasAcc.containsKey(opp.KS_Distribuidor__c) ) 
            { oppCnt = ofertasAcc.get(opp.KS_Distribuidor__c); }
            oppCnt.add(opp.ID); ofertasAcc.put(opp.KS_Distribuidor__c, oppCnt);
        }
        System.debug('-------------------------JCAR - ACCOUNT OFERTAS - ' + ofertasAcc.size() + ' - ' + ofertasAcc);
        
        // Set estados
        
        for (ID accID : sobjIDLst) {
            
            Set<ID> evCnt = eventosAcc.get(accID);
            Set<ID> oppCnt = ofertasAcc.get(accID);
            
            Account acc = new Account();
            if (accMap.containsKey(acc.ID)) { acc = accMap.get(acc.ID); }
            
            acc.ID = accID;
            acc.KS_Estado_candidato__c = 'A explorar';
            
            if (evCnt != null) {
                acc.KS_Estado_candidato__c = 'En prospección';
                if (evCnt.size()>2) {
                	acc.KS_Estado_candidato__c = 'En maduración';    
                }
            }
            
            if (oppCnt != null) {
                acc.KS_Estado_candidato__c = 'Oportunidad en curso';
            }
            
            accMap.put(acc.ID, acc);
        }
        
        System.debug('-------------------------JCAR - ACCOUNT UPDATE - ' + accMap.size() + ' - ' + accMap.values());
        Database.SaveResult[] savRes = Database.update(accMap.values(), true);
    }
    
    global void finish(Database.BatchableContext BC){
    }
    
    private String getProfile() {
        List<Profile> profLst = [SELECT ID,Name FROM Profile];
        for (Profile prof : profLst) {
            if (prof.ID == userInfo.getProfileId()) { return prof.Name; }
        }
        return '';
    }      
}