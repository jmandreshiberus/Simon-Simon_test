@isTest
public class KS_TEST_Schedule_SIMON {
    
    @isTest static KS_Schedule_SIMON_Controller test_KS_Schedule_SIMON_Controller() {
        ApexPages.StandardController sc = new ApexPages.StandardController(new Account());
        return new KS_Schedule_SIMON_Controller(sc);
    }
        
    @isTest static void test_callBatchNormalizacion_Accounts() {
        KS_Schedule_SIMON_Controller control = test_KS_Schedule_SIMON_Controller();
        control.callBatchNormalizacion_Accounts();
    }
    @isTest static void test_callBatchNormalizacion_Contacts() {
        KS_Schedule_SIMON_Controller control = test_KS_Schedule_SIMON_Controller();
        control.callBatchNormalizacion_Contacts();
    }
}