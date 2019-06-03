global class ConvertAttachmentsKSUtils {

    global static Map<String, ID> getRecordType() {
        
        Map<String, ID> rtM = new Map<String, ID>();
        for (RecordType rt : [SELECT ID, DeveloperName FROM RecordType]) {
            rtM.put(rt.DeveloperName, rt.ID);
        }
        return rtM;
    }
    
    global static Profile getProfile() {
        return [SELECT ID, Name FROM Profile WHERE Name = 'Usuario estándar' or Name = 'Standard User' LIMIT 1];
    }    
    
    global static User newUser( ID profileId, String firstName, String lastName, String email ) {
        Integer rand = Math.round( Math.random() * 1000 );
        return new User(
            isActive = true,
            profileId = profileId,
            alias = firstName.substring(0,1) + lastName.substring(1,5),
            firstName = firstName,
            lastName = lastName,
            email = email,
            username = rand + email,
            emailEncodingKey = 'UTF-8',
            languageLocaleKey = 'en_US',
            localeSidKey = 'en_US',
            timeZoneSidKey = 'America/Chicago',
            KS_IDSAP__c = ConvertAttachmentsKSUtils.generateRandomDocument(8)
        );
    }
    
    global static Account newAccount( ID ownerID, String name, Integer accId, Map<String, ID> rtM ) {
        
        ID rt = rtM.get('KS_Distribuidores_SAP');
        Account acc = 
            new Account(
                RecordTypeId = rt,
                Name = name+accId,
                KS_Id_SAP__c = 'IDSAPTEST1234-'+accId,
                Phone = '666666666',
                BillingCountryCode = 'ES',
                BillingCity = 'Barcelona',
                BillingPostalCode = '08907',
                BillingStreet = 'Calle de gracia',
                KS_Grupo_de_ctas_deudor__c = '0001',
                KS_Idioma__c = 'ES',
                KS_Nombre_2__c = 'Cliente Distribuidor TEST',
                KS_N_identificacion_fiscal_suplementario__c = '1',
                KS_Numero_de_identificacion_fiscal_1__c = '1',
                KS_N_de_telefono_2__c = '1',
                KS_Actividad__c = 'Distribuidor',
                KS_Canal__c = 'Distribuidores SAP'
            );
        if (ownerID != null) { acc.OwnerId = OwnerId; }
        return acc;
    }

    global static string generateRandomDocument(integer len){
        string document = '';
        string nums = '0123456789';
        for(integer i=0; i<len; i++){
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), nums.length());
            document += nums.substring(idx,idx+1);
        }
        return document;
    }
    
}