global without sharing class KS_Batch_CondicionesComerciales_Delete implements Database.Batchable<sObject>{
    
    global final String Query;
    global final String Entity;
    global final String Field;
    global final String Value;
    /*
    public static void deleteCondicionesComerciales() {
                
        Datetime dt = Datetime.now().addDays(-1);
        System.debug('-------------------------JCAR - DELETE Condiciones Comerciales de ' + dt.format() + ' o anterior.');
        
        String q = 'SELECT ID FROM KS_Condicion_Comercial__c WHERE CreatedDate <= ' + dt.format('YYYY-MM-dd\'T\'kk:mm:ss')+'.000+0000';
        String e = 'KS_Condicion_Comercial__c';
        Id batchInstanceId = Database.executeBatch(new KS_Batch_CondicionesComerciales_Delete(q,e,'',''), 5000);

        System.debug('-------------------------JCAR - DELETE BATCH CON ID' + batchInstanceId);
    }
    */
    global KS_Batch_CondicionesComerciales_Delete(String q, String e, String f, String v){
        
        System.debug('-------------------------JCAR - QUERY - ' + q);
        Query=q; Entity=e; Field=f;Value=v;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('-------------------------JCAR - QUERY - ' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        System.debug('-------------------------JCAR - SCOPE - ' + SCOPE.size());
        //delete scope;
        Database.DeleteResult[] delRes = Database.delete(scope, false);
    }
    
    global void finish(Database.BatchableContext BC){
    }
}