@isTest
public class KS_RGProteccionDatos_TEST {

    @testSetup static void TEST_SETUP_RGProteccionDatos() {
        Lead can = new Lead();
        can.FirstName = 'Kaizen';
        can.LastName = 'Step';
        can.Phone = '333222111';
        can.Email = 'kstep@kaizen.com';
        can.Company = 'KaizenStep';
        can.KS_Tipo_de_via__c = 'AVENIDA';
        can.KS_Calle__c = 'MERIDIANA';
        can.KS_N_m_portal_piso_puerta_y_resto_domici__c = '354, 5A';
        can.KS_C_digo_Postal__c = '08027';
        can.KS_Ciudad__c = 'BARCELONA';
        can.KS_Estado_o_Provincia__c = 'BARCELONA';
        can.KS_Pais__c = 'ES';
        can.KS_RechazoComunicaciones__c = true;
        insert can;
        
        KS_Trigger_Test.disableTrigger();
        KS_TEST_FUNCTIONS tstfnc = new KS_TEST_FUNCTIONS();
        Map<String, ID> rtM = KS_TEST_FUNCTIONS.getRecordTypeStatic();
        Account acc = tstfnc.createAccDistribuidor(rtM);
        Contact con = tstfnc.createContact(acc);
        KS_Trigger_Test.enableTrigger();
    }
    public static testMethod void TEST_RGProteccionDatos_Lead() {
        Lead sobj = [SELECT ID FROM Lead limit 1];
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(sobj);
        KS_RGProteccionDatos_Controller control = new KS_RGProteccionDatos_Controller(sc);
        control.led.KS_Consentimiento__c = true;
        control.led.KS_RechazoComunicaciones__c = false;
        control.save();
        control.cancel();
        control.getReturnURL();
        control.led = null;
        control.getReturnURL();
    }
    public static testMethod void TEST_RGProteccionDatos_Account() {
        Account sobj = [SELECT ID FROM Account limit 1];
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(sobj);
        KS_RGProteccionDatos_Controller control = new KS_RGProteccionDatos_Controller(sc);
        control.save();
        control.cancel();
        control.getReturnURL();
    }
    public static testMethod void TEST_RGProteccionDatos_Contact() {
        Contact sobj = [SELECT ID FROM Contact limit 1];
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(sobj);
        KS_RGProteccionDatos_Controller control = new KS_RGProteccionDatos_Controller(sc);
        control.save();
        control.cancel();
        control.getReturnURL();
    }
    public static testMethod void TEST_RGProteccionDatos_STATIC() {
        KS_RGProteccionDatos_Controller.getIsAdmin();
    }
}