@isTest
public class KS_TEST_Debug {

    public static Boolean isRunning = false;
    
    public static testMethod VOID TEST_processSaveResult() {

        KS_Trigger_Test.disableTrigger();
        KS_TEST_FUNCTIONS tf = new KS_TEST_FUNCTIONS();
        Map<String, ID> rtM = KS_TEST_FUNCTIONS.getRecordTypeStatic();
        Account acc = tf.createAccDistribuidor(rtM);
        
        isRunning = true;
        
        Map<String,sObject> data = new Map<String,sObject>(); data.put(acc.ID, acc);
        List<Database.SaveResult> saveResult = Database.update(data.values(), false);
        
        Test.startTest();
        KS_Trigger_Test.enableTrigger();
        
        System.debug('TEST_processSaveResult saveResult ' + saveResult);
        List<KS_Debug__c> res = KS_Debug_Utils.processSaveResult(saveResult, data, 'KS_TEST_Debug', 'TEST_processSaveResult');
        System.debug('TEST_processSaveResult List<KS_Debug__c> ' + res);
        //System.assertEquals(res.isEmpty(), false);
        
        Test.stopTest();
    }
}