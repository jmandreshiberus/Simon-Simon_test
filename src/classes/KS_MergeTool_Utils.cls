global without sharing class KS_MergeTool_Utils {

    public static Map<Id,Account> getAccountMapBySetId(Set<ID> idSet) {
        return new Map<Id,Account>(
            [SELECT Id, Name, KS_Canal__c, KS_Actividad__c, KS_Subactividad__c, KS_Sector__c, 
             BillingStreet, BillingCity, BillingPostalCode, BillingState, BillingCountryCode,
             Phone, KS_N_de_telefono_2__c, KS_N_de_telefono_3__c, KS_Email__c
             FROM Account WHERE Id In :idSet]
        );
    }
    public static Map<Id,String> getAccountOwnerUserNameMap(Set<ID> idSet) {
        Map<Id,String> mapa = new Map<Id,String>();
        for (Account acc : [SELECT Id, Owner.UserName FROM Account WHERE Id In :idSet]) {
            mapa.put(acc.ID, acc.Owner.UserName);
        }
        return mapa;
    }
    
    public static Map<Id,Contact> getContactMapBySetId(Set<ID> idSet) {
        return new Map<Id,Contact>(
            [SELECT Id, Name, OtherStreet, OtherCity, OtherPostalCode, OtherState, OtherCountry,
             Phone, MobilePhone, HomePhone, Email, KS_Funcion_en_empresa__c, KS_Idioma__c
             FROM Contact WHERE Id In :idSet]
        );
    }
    public static Map<Id,String> getContactOwnerUserNameMap(Set<ID> idSet) {
        Map<Id,String> mapa = new Map<Id,String>();
        for (Contact con : [SELECT Id, Owner.UserName FROM Contact WHERE Id In :idSet]) {
            mapa.put(con.ID, con.Owner.UserName);
        }
        return mapa;
    }
    
    public static KS_Debug__c debugNew(String cls, String apx, String mtd, KS_Fusion__c fus) {
        return KS_Debug_Utils.newFusionDebug(cls, apx, mtd, fus.KS_Id_Principal__c);
    }
    public static KS_Debug__c debugDesc(String cls, String apx, String mtd, String dsc, KS_Fusion__c fus) {
        return KS_Debug_Utils.newFusionDebugDesc(cls, apx, mtd, dsc, fus.KS_Id_Principal__c);
    }

    public static Map<String, String> accountFusionFieldsMap() {
        Map<String, String> campos = new Map<String, String>();
        campos.put('KS_Acc_Calle__c', 'BillingStreet');
        campos.put('KS_Acc_Ciudad__c', 'BillingCity');
        campos.put('KS_Acc_Codigo_Postal__c', 'BillingPostalCode');
        campos.put('KS_Acc_Estado_Provincia__c', 'BillingState');
        campos.put('KS_Acc_Pais__c', 'BillingCountryCode');
        campos.put('KS_Acc_Telefono__c', 'Phone');
        campos.put('KS_Acc_Telefono_2__c', 'KS_N_de_telefono_2__c');
        campos.put('KS_Acc_Telefono_3__c', 'KS_N_de_telefono_3__c');
        campos.put('KS_Acc_Correo__c', 'KS_Email__c');
        campos.put('KS_Acc_Canal__c', 'KS_Canal__c');
        campos.put('KS_Acc_Actividad__c', 'KS_Actividad__c');
        campos.put('KS_Acc_Subactividad__c', 'KS_Subactividad__c');
        campos.put('KS_Acc_Sector__c', 'KS_Sector__c');
        return campos;
    }
    public static Map<String, String> contactsFusionFieldsMap() {
        Map<String, String> campos = new Map<String, String>();
        campos.put('KS_Ctc_Calle__c', 'OtherStreet');
        campos.put('KS_Ctc_Ciudad__c', 'OtherCity');
        campos.put('KS_Ctc_Codigo_Postal__c', 'OtherPostalCode');
        campos.put('KS_Ctc_Estado_Provincia__c', 'OtherState');
        campos.put('KS_Ctc_Pais__c', 'OtherCountry');
        campos.put('KS_Ctc_Telefono__c', 'Phone');
        campos.put('KS_Ctc_Movil__c', 'MobilePhone');
        campos.put('KS_Ctc_Telefono_Particular__c', 'HomePhone');
        campos.put('KS_Ctc_Correo__c', 'Email');
        campos.put('KS_Ctc_Funcion_en_empresa__c', 'KS_Funcion_en_empresa__c');
        campos.put('KS_Ctc_Idioma__c', 'KS_Idioma__c');
        return campos;
    }
    public static Boolean campoNotFull(String campo, SObject obj) {
        return obj.get(campo) != null && ((String)obj.get(campo) != '');
    }
    
    public static List<KS_Debug__c> debugAccount(String apx, String mtd, KS_Fusion__c fus, Account acc, Account ac2, Account ac3, ID rtID, String owner) {
        return KS_MergeTool_Utils.debugSObject('Account', apx, mtd, fus, 'Name', acc, new List<sObject>{ac2, ac3}, KS_MergeTool_Utils.accountFusionFieldsMap(), rtID, owner);
    }
    public static List<KS_Debug__c> debugContact(String apx, String mtd, KS_Fusion__c fus, Contact con, Contact co2, Contact co3, ID rtID, String owner) {
        return KS_MergeTool_Utils.debugSObject('Contact', apx, mtd, fus, 'Name', con, new List<sObject>{co2, co3}, KS_MergeTool_Utils.contactsFusionFieldsMap(), rtID, owner);
    }
    
    // cls = clase del objeto fusionado (Account, Contact)
    // apx = clase apex que llama
    // mtd = metodo apex que llama
    // fus = objeto Fusion a procesar
    // keyfield = nombre de campo identificativo de objetos
    // sObj = objetos principal de la fusión
    // sObjLst = lista de objetos vinculados a fusión (duplicado_1, duplicado_2)
    // campos = mapeo nombre campos <fusion, objeto>
    // rtID = Debug RecordTypeId
    // owner = propietario/s del objeto fusionado
    public Static List<KS_Debug__c> debugSObject(String cls, String apx, String mtd, KS_Fusion__c fus, String keyField, sObject sObj, List<sObject> sObjLst, Map<String, String> campos, ID rtID, String owner) {
        List<KS_Debug__c> debugList = new List<KS_Debug__c>();
        
        // Se creará un objeto fusión por cada duplicado
        // se guardará el valor original de tanto el principal como el duplicado
        // todo en campos String, se separará ambos valores por una ; y un >, o sea: valor1 ; valor2 ; valor3 > valorNuevo
        sObjLst = sObjLst != null ? sObjLst : new List<sObject>();
        for (sObject sObjDupli : sObjLst) {
            if (sObjDupli == null) {continue;}
            KS_Debug__c debug = KS_Debug_Utils.debugObjectFieldsLst(
                cls, apx, mtd, fus.KS_Id_Principal__c, keyField, 
                fus, new List<sObject>{sObj, sObjDupli}, campos);
            
            debug.KS_Descripcion__c = 'Histórico de: \r\n' + sObj.get(keyField) + '; \r\n' + sObjDupli.get(keyField);
            debug.RecordTypeId = rtID; debugList.add(debug);
            debug.KS_Master_Owner__c = owner;
            if (cls == 'Account') { debug.KS_Master_Account__c = fus.KS_Id_Principal__c; }
            if (cls == 'Contact') { debug.KS_Master_Contact__c = fus.KS_Id_Principal__c; }
            //if (cls == 'Organización Cliente') { debug.KS_Master_Marca__c = fus.KS_Id_Principal__c; }
        }
        
        return debugList;
    }
    
    /*

	MAP CAMPOS FUSION > OBJETO
	MAP CAMPOS OBJETO > DEPURACIÓN

	*/
}