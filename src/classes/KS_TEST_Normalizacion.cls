@isTest
public class KS_TEST_Normalizacion {

    public static testMethod Boolean TEST_getConfiguration() {
        
        Map<String,Boolean> conf = KS_Normalizacion_Utils.getConfigurationFlags();
        System.debug('TEST_getConfiguration KS_GlobalTriggerControl KS_Normalizacion ' + conf);
        System.assertEquals(conf.isEmpty(), false);

        Boolean oldValue = false || conf.get('NormalizacionCuentaStatus');
        
        KS_Normalizacion_Utils.setConfigurationFlag('NormalizacionCuentaStatus', false);
        System.assertEquals(false, KS_Normalizacion_Utils.getConfigurationFlag('NormalizacionCuentaStatus'));

        KS_Normalizacion_Utils.setConfigurationFlag('NormalizacionCuentaStatus', conf.get('NormalizacionCuentaStatus'));
        System.assertEquals(conf.get('NormalizacionCuentaStatus'), KS_Normalizacion_Utils.getConfigurationFlag('NormalizacionCuentaStatus'));
        
        KS_Normalizacion_Utils.setConfigurationFlag('NormalizacionCuentaStatus', oldValue);
        System.assertEquals(oldValue, KS_Normalizacion_Utils.getConfigurationFlag('NormalizacionCuentaStatus'));
        
        System.debug('TEST_getConfiguration KS_GlobalTriggerControl KS_Normalizacion ' + conf);
        
        return !conf.isEmpty();
    }
    
    public static testMethod Boolean TEST_cleanString() {
        String cleanMe = '(K  [a+i{z-e, n_S}t*e]p/.)';
        String cleaned = KS_Normalizacion.cleanString(cleanMe);
        System.debug('TEST_cleanString assertEquals ' + (cleaned == 'KaizenStep') + ' ' + cleaned);
        System.assertEquals(cleaned,'KaizenStep');
        return cleaned == 'KaizenStep';
    }
    
    public static testMethod Boolean TEST_capitalize() {
        String cleanMe = 'kAiZen  stEp ';
        String cleaned = KS_Normalizacion.capitalize(cleanMe);
        System.debug('TEST_capitalize assertEquals ' + (cleaned == 'Kaizen Step') + ' ' + cleaned);
        System.assertEquals(cleaned,'Kaizen Step');
        return cleaned == 'Kaizen Step';
    }
    
    public static Account getAccount() {
        
        KS_Trigger_Test.disableTrigger();
        KS_TEST_FUNCTIONS tf = new KS_TEST_FUNCTIONS();
        Account acc = tf.createAccDistribuidor(tf.getRecordType());
        KS_Trigger_Test.enableTrigger();
        
        acc.Name = 'kAiZeNStEp s.L - clOuD SOlUtiOnS & SeRvIcEs Sl';
        acc.Phone = '902.002.373';
        acc.KS_N_de_telefono_2__c = '902-002-373';
        acc.KS_N_de_telefono_3__c = '902 002  373';
        
        acc.BillingCity = 'Barcelona';
        acc.BillingPostalCode = '08001';      
        acc.BillingStreet = 'Calle Genérica 11';
        acc.KS_BillingCity__c = 'Valencia';
        acc.KS_BillingPostalCode__c = '0912';      
        acc.KS_BillingStreet__c = 'Calle Genérica 12';
        acc.ShippingCity = 'Barcelona';
        acc.ShippingPostalCode = '08001';
        acc.ShippingStreet = 'Calle Genérica 11';
        acc.KS_ShippingCity__c = 'BARceLona';
        acc.KS_ShippingPostalCode__c = '08002';
        acc.KS_ShippingStreet__c = 'Avenida Talcuala 33';
        
        acc.KS_Ciudad__c = acc.KS_BillingCity__c;
        acc.KS_C_digo_Postal__c = acc.KS_BillingPostalCode__c;
        acc.KS_Tipo_de_via__c = 'Calle';
        acc.KS_Calle__c = 'Genérica';
        acc.KS_N_m_portal_piso_puerta_y_resto_de_di__c = '12';
        return acc;
    }
    
    public static testMethod Account TEST_normalizarAccount() {
       
        Account old = getAccount();
        Map<String,Account> objetos = new Map<String,Account>(); objetos.put('TEST',old);
        Map<String,Boolean> config = KS_Normalizacion_Utils.getConfigurationFlags();
        
        KS_Normalizacion_Utils.setConfigurationFlag('NormalizacionCuentaLevenshtein', false);
        Account obj = (Account)KS_Normalizacion.normalizarAccount(objetos).get('TEST');
        
        System.debug('TEST_normalizarAccount assertEquals ' + (obj.Name == 'KAIZENSTEP S.L - CLOUD SOLUTIONS & SERVICES SL') + ' ' + obj.Name);
        System.assertEquals(obj.Name,'KAIZENSTEP S.L - CLOUD SOLUTIONS & SERVICES SL');
        
        System.debug('TEST_normalizarAccount assertEquals ' + (obj.Phone == '902002373') + ' ' + obj.Phone);
        System.assertEquals(obj.Phone,'902002373');
        
        System.debug('TEST_normalizarAccount assertEquals ' + (obj.KS_N_de_telefono_2__c == '902002373') + ' ' + obj.KS_N_de_telefono_2__c);
        System.assertEquals(obj.KS_N_de_telefono_2__c,'902002373');
        
        System.debug('TEST_normalizarAccount assertEquals ' + (obj.KS_N_de_telefono_3__c == '902002373') + ' ' + obj.KS_N_de_telefono_3__c);
        System.assertEquals(obj.KS_N_de_telefono_3__c,'902002373');
        
        KS_Normalizacion_Utils.setConfigurationFlag('NormalizacionCuentaLevenshtein', true);
        old.BillingCity = 'Barcelona'; old.KS_BillingCity__c = ''; old.KS_Ciudad__c = ''; objetos.put('TEST', old);
        obj = (Account)KS_Normalizacion.normalizarAccount(objetos).get('TEST');
        for (String campo : obj.getPopulatedFieldsAsMap().keySet()) { System.debug('TEST_normalizarAccount campo ' + campo + ' = ' + obj.get(campo)); }      
        System.assertEquals(obj.BillingCity,'Barcelona');
        
        return obj;
    }
    
    public static Contact getContact() {
        
        KS_Trigger_Test.disableTrigger();
        KS_TEST_FUNCTIONS tf = new KS_TEST_FUNCTIONS();
        Map<String, ID> rtm = tf.getRecordType();
        Account acc = tf.createAccDistribuidor(rtm);
        Contact con = tf.createContact(acc);
        KS_Trigger_Test.enableTrigger();
        
        con.FirstName = ' kAiZen stEp';
        con.LastName = 'clOuD SOlUtiOnS  & SeRvIcEs  ';
        con.Phone = '902.002.373';
        con.MobilePhone = '902-002-373';
        con.HomePhone = '902  002 373';
        return con;
    }
    
    public static testMethod Contact TEST_normalizarContact() {
        
        Map<String,Boolean> config = KS_Normalizacion_Utils.getConfigurationFlags();
        
        Contact old = getContact();
        Map<String,Contact> objetos = new Map<String,Contact>(); objetos.put('TEST',old);
        
        KS_Normalizacion_Utils.setConfigurationFlag('NormalizacionContactoCapital', true);
        
        Contact obj = (Contact)KS_Normalizacion.normalizarContact(objetos).get('TEST');
        
        System.debug('TEST_normalizarContact assertEquals ' + (obj.FirstName == 'KAIZEN STEP') + ' ' + obj.FirstName);
        System.assertEquals(obj.FirstName,'KAIZEN STEP');
        
        System.debug('TEST_normalizarContact assertEquals ' + (obj.LastName == 'CLOUD SOLUTIONS & SERVICES') + ' ' + obj.LastName);
        System.assertEquals(obj.LastName,'CLOUD SOLUTIONS & SERVICES');
        
        KS_Normalizacion_Utils.setConfigurationFlag('NormalizacionContactoCapital', false);

        obj = (Contact)KS_Normalizacion.normalizarContact(objetos).get('TEST');
        
        System.debug('TEST_normalizarContact assertEquals ' + (obj.FirstName == 'Kaizen Step') + ' ' + obj.FirstName);
        System.assertEquals(obj.FirstName,'Kaizen Step');
        
        System.debug('TEST_normalizarContact assertEquals ' + (obj.LastName == 'Cloud Solutions & Services') + ' ' + obj.LastName);
        System.assertEquals(obj.LastName,'Cloud Solutions & Services');
        
        System.debug('TEST_normalizarContact assertEquals ' + (obj.Phone == '902002373') + ' ' + obj.Phone);
        System.assertEquals(obj.Phone,'902002373');
        
        System.debug('TEST_normalizarContact assertEquals ' + (obj.MobilePhone == '902002373') + ' ' + obj.MobilePhone);
        System.assertEquals(obj.MobilePhone,'902002373');
        
        System.debug('TEST_normalizarContact assertEquals ' + (obj.HomePhone == '902002373') + ' ' + obj.HomePhone);
        System.assertEquals(obj.HomePhone,'902002373');
        return obj;
    }
    
    public static testMethod void TEST_BATCH_Account_execute() {

        update getAccount();

        Test.startTest();
        KS_Batch_Normalizacion batchNormal = new KS_Batch_Normalizacion(
            KS_Batch_Normalizacion.getQueryAccount(),
            Account.class.getName()
        );
        DataBase.executeBatch(batchNormal);
        Test.stopTest();
    }
    public static testMethod void TEST_BATCH_Contact_execute() {
        
        update getContact();

        Test.startTest();
        KS_Batch_Normalizacion batchNormal = new KS_Batch_Normalizacion(
            KS_Batch_Normalizacion.getQueryContact(),
            Contact.class.getName()
        );
        DataBase.executeBatch(batchNormal);
        Test.stopTest();
    }
}