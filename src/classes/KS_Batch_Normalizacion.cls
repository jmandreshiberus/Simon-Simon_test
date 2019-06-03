global class KS_Batch_Normalizacion implements Database.Batchable<sObject> {
    
    public String query {get;set;}
    public String sObjectType {get;set;}
        
	global KS_Batch_Normalizacion(String q, String t) {
		query = q;
        sObjectType = t;
	}
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) 
    {
        System.debug('-- JCAR -- KS_Batch_Normalizacion ----------------- scope ' 
                     + scope.size() + ' List<sObject> ' + scope);
        KS_Normalizacion_Utils.executeNormalizacion(sObjectType, scope);
    }

    global void finish(Database.BatchableContext BC) {}

    global static String getQueryAccount() {
        return ('SELECT ID, Name, Phone, KS_N_de_telefono_2__c, KS_N_de_telefono_3__c'
                + ', BillingCity, BillingPostalCode, BillingStreet'
                + ', KS_BillingCity__c, KS_BillingPostalCode__c, KS_BillingStreet__c'
                + ', KS_BillingCity_Diff__c, KS_BillingPostalCode_Diff__c, KS_BillingStreet_Diff__c'
                + ', ShippingCity, ShippingPostalCode, ShippingStreet'
                + ', KS_ShippingCity__c, KS_ShippingPostalCode__c, KS_ShippingStreet__c'
                + ', KS_ShippingCity_Diff__c, KS_ShippingPostalCode_Diff__c, KS_ShippingStreet_Diff__c'
                + ', KS_Tipo_de_via__c, KS_Calle__c, KS_N_m_portal_piso_puerta_y_resto_de_di__c, KS_Ciudad__c, KS_C_digo_Postal__c'
                + ' FROM Account');
    }
    global static String getQueryContact() {
        return ('SELECT ID, FirstName, LastName, Phone, MobilePhone, HomePhone '
                + ' FROM Contact');
    }
}