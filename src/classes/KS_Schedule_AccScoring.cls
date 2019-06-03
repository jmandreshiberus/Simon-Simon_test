global without sharing class KS_Schedule_AccScoring implements Schedulable {
    
    global Integer chunks = 200;
    global KS_Schedule_AccScoring(Integer ch) { chunks = ch != null && ch > 0 ? ch : 200; }
    
    global void execute(SchedulableContext sc) {

        String rt = '(\'Distribuidores CRM\', \'Distribuidores SAP\', \'Clientes finales\', \'Prescriptores\', \'Instalador\')';
        String q = 'SELECT ID, KS_recordType_Name__c, KS_Canal__c FROM Account WHERE KS_Canal__c in '+rt;
        String e = 'Account';
        
        Id batchInstanceId = Database.executeBatch(new KS_Batch_AccScoring(q,e,'',''), chunks);
        System.debug('-------------------------JCAR - BATCH CON ID' + batchInstanceId);
    }
}