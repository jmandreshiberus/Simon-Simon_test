global without sharing class KS_Schedule_Cuentas implements Schedulable {

    //CRON_EXP = Seconds Minutes Hours Day_of_month Month Day_of_week optional_year 
    //(El "Month" puede ser una lista concreta de meses sin espacio y separados por comas --> '1,4,5,8')
    /*
    public static String CRON_EXP = '0 30 00 * * ?';//En este caso ejecutamos el proceso cada dia a 00:30
    
    global static String scheduleIt() {
        KS_Schedule_Cuentas sc = new KS_Schedule_Cuentas();
        return System.schedule('Daily - Lead - Status Update', CRON_EXP, sc);
    }
    */
    global void execute(SchedulableContext sc) {

        String rt = 'KS_Lead';
        String q = 'SELECT ID FROM Account WHERE KS_recordType_Name__c = \''+rt+'\'';
        String e = 'Account';
        
        Id batchInstanceId = Database.executeBatch(new KS_Batch_Cuentas(q,e,'',''), 200);
        System.debug('-------------------------JCAR - BATCH CON ID' + batchInstanceId);        
    }
}