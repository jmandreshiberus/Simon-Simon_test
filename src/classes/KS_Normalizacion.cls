public class KS_Normalizacion {

    public static Map<String,sObject> normalizarAccount(Map<String,sObject> objetos) { return normalizar(objetos, Account.class.getName()); }
    public static Map<String,sObject> normalizarContact(Map<String,sObject> objetos) { return normalizar(objetos, Contact.class.getName()); }
    
    public static Map<String,sObject> normalizar(Map<String,sObject> objetos, String sObjectType) {
        if (sObjectType == null) {return objetos;} if (sObjectType.trim() == '') {return objetos;}
        Map<String,Decimal> levenshteinDistance = KS_LevenshteinDistance_Utils.levenshteinDistanceFrom(sObjectType);

        Map<String,sObject> procesado = new Map<String,sObject>();
        for (String k : objetos.keySet()) {
            sObject sObj = objetos.get(k);
            if (sObjectType == Account.class.getName()) { procesado.put(k,cleanAccount(sObj, levenshteinDistance)); } 
            else if (sObjectType == Contact.class.getName()) { procesado.put(k,cleanContact(sObj)); }
        }
        return procesado;
    }
    
    public static Account cleanAccount(sObject sObj) { return cleanAccount(sObj, null); }
    public static Account cleanAccount(sObject sObj, Map<String,Decimal> levenshteinDistance) {
        if (sObj == null) {return new Account();}
        Account obj = setDirecciones((Account)sObj);
        System.debug('-- -- -- -- cleanAccount of ' + sObj.getPopulatedFieldsAsMap());
        // Cuentas (Nombre de la cuenta, Teléfono, Teléfono 2, Teléfono 3)
        if (sObj.get('Name') != null) { obj.Name = ((String)sObj.get('Name')).toUpperCase().normalizeSpace().trim(); }
        if (sObj.get('Phone') != null) { obj.Phone = cleanString((String)sObj.get('Phone')); }
        if (sObj.get('KS_N_de_telefono_2__c') != null) { obj.KS_N_de_telefono_2__c = cleanString((String)sObj.get('KS_N_de_telefono_2__c')); }
        if (sObj.get('KS_N_de_telefono_3__c') != null) { obj.KS_N_de_telefono_3__c = cleanString((String)sObj.get('KS_N_de_telefono_3__c')); }
        if (levenshteinDistance != null && !levenshteinDistance.isEmpty()) { obj = levenshteinDistanceAccount(obj, levenshteinDistance); }
        obj.ID = sObj.ID;
        System.debug('-- -- -- -- cleanAccount of ' + obj.getPopulatedFieldsAsMap());
        return obj;
    }
    public static Contact cleanContact(sObject sObj) {
        Contact obj = new Contact();
        if (sObj == null) {return obj;}
        System.debug('-- -- -- -- cleanContact of ' + sObj.getPopulatedFieldsAsMap());
        // Contactos (Nombre, Apellidos, Teléfono, Móvil, Telf Particular)
        if (KS_Normalizacion_Utils.getConfigurationFlag('NormalizacionContactoCapital')) {
            if (sObj.get('FirstName') != null) { obj.FirstName = ((String)sObj.get('FirstName')).toUpperCase().normalizeSpace().trim(); }
            if (sObj.get('LastName') != null) { obj.LastName = ((String)sObj.get('LastName')).toUpperCase().normalizeSpace().trim(); }
        } else {
            if (sObj.get('FirstName') != null) { obj.FirstName = capitalize((String)sObj.get('FirstName')); }
            if (sObj.get('LastName') != null) { obj.LastName = capitalize((String)sObj.get('LastName')); }
        }
        if (sObj.get('Phone') != null) { obj.Phone = cleanString((String)sObj.get('Phone')); }
        if (sObj.get('MobilePhone') != null) { obj.MobilePhone = cleanString((String)sObj.get('MobilePhone')); }
        if (sObj.get('HomePhone') != null) { obj.HomePhone = cleanString((String)sObj.get('HomePhone')); }
        obj.ID = sObj.ID;
        return obj;
    }
    
    public Static String cleanString(String cleanMe) {
        if (cleanMe == null) {return '';}
        // espacio, tabulador, coma, punto, - _ * + / 
        String cleaned = cleanMe.trim().normalizeSpace().replaceAll('(\\s|\\t|\\,|\\.|\\-|\\_|\\*|\\+|\\/|\\(|\\[|\\{|\\(|\\[|\\{|\\(|\\[|\\{|\\}|\\]|\\))', '');
        return cleaned;
    }
    
    public Static String capitalize(String capMe) {
        if (capMe == null) {return '';}
        String normalized = capMe.normalizeSpace().trim().toLowerCase();
        List<String> words = new List<String>();
        for (String w : normalized.split(' ')) {
            words.add(w.capitalize());
        }
        return String.join(words, ' ');
    }
    
    public Static Account levenshteinDistanceAccount(Account acc, Map<String,Decimal> levenshteinDistance) {
        if (acc == null) { return acc; }
        
        Boolean autoEdit = KS_Normalizacion_Utils.getConfigurationFlag('NormalizacionCuentaLevenshtein');
        autoEdit = autoEdit == null ? false : autoEdit;
        if (autoEdit && levenshteinDistance == null) { return acc; }
        if (autoEdit && levenshteinDistance != null && levenshteinDistance.isEmpty()) { return acc; }
        
        if (!autoEdit) { return levenshteinGetDistanceAccount(acc); }
        
        acc.BillingStreet = (String)levenshteinDistanceField(acc,'BillingStreet','KS_BillingStreet__c',levenshteinDistance);
        acc.BillingPostalCode = (String)levenshteinDistanceField(acc,'BillingPostalCode','KS_BillingPostalCode__c',levenshteinDistance);
        acc.BillingCity = (String)levenshteinDistanceField(acc,'BillingCity','KS_BillingCity__c',levenshteinDistance);
        
        acc.ShippingStreet = (String)levenshteinDistanceField(acc,'ShippingStreet','KS_ShippingStreet__c',levenshteinDistance);
        acc.ShippingPostalCode = (String)levenshteinDistanceField(acc,'ShippingPostalCode','KS_ShippingPostalCode__c',levenshteinDistance);
        acc.ShippingCity = (String)levenshteinDistanceField(acc,'ShippingCity','KS_ShippingCity__c',levenshteinDistance);
        
        return acc;
    }
    
    public static Object levenshteinDistanceField(sObject obj, String oldField, String newField, Map<String,Decimal> levenshteinDistance) {
        
        if (obj == null) { return obj; }
        if (obj.get(oldField) == null) { return obj.get(oldField); }
        if (obj.get(newField) == null) { return obj.get(oldField); }
        if ((String)obj.get(newField) == '') { return obj.get(oldField); }
        
        Boolean autoEdit = KS_Normalizacion_Utils.getConfigurationFlag('NormalizacionCuentaLevenshtein');
        autoEdit = autoEdit == null ? false : autoEdit;
        if (autoEdit && levenshteinDistance == null) { return obj.get(oldField); }
        if (autoEdit && levenshteinDistance != null && levenshteinDistance.isEmpty()) { return obj.get(oldField); }

        if( !levenshteinDistance.containsKey(oldField) ) { return obj.get(oldField); }
        Decimal diff = levenshteinDistance.get(oldField);
        if (diff == null) { return obj; } //if (diff == 0) { return obj.get(oldField); }
        
        obj.put(oldField, 
                KS_LevenshteinDistance_Utils.levenshteinDistanceByPercentage(
                    (String)obj.get(oldField), (String)obj.get(newField), diff)
               );
        return obj.get(oldField);
    }
    
    public static Account levenshteinGetDistanceAccount(Account acc) {
        
        System.debug('-- JCAR -- levenshteinGetDistanceAccount acc ' + acc);

        Cuenta cuen = new Cuenta(acc);
        cuen.setDiff();
        
        acc = levenshteinGetDistanceAccountMedia(cuen.data);
        
        return acc;
    }
    
    public static Account levenshteinGetDistanceAccountMedia(Account acc) {
        
        String totalOld = ''; String totalNew = '';
        Decimal media = 0;
        if (acc == null) {return acc;}
        
        totalOld += levenshteinGetDistanceAccountMediaGetField(acc,'BillingStreet')[0];
        totalNew += levenshteinGetDistanceAccountMediaGetField(acc,'BillingStreet')[1];
        totalOld += levenshteinGetDistanceAccountMediaGetField(acc,'BillingPostalCode')[0];
        totalNew += levenshteinGetDistanceAccountMediaGetField(acc,'BillingPostalCode')[1];
        totalOld += levenshteinGetDistanceAccountMediaGetField(acc,'BillingCity')[0];
        totalNew += levenshteinGetDistanceAccountMediaGetField(acc,'BillingCity')[1];
        
        totalOld += levenshteinGetDistanceAccountMediaGetField(acc,'ShippingStreet')[0];
        totalNew += levenshteinGetDistanceAccountMediaGetField(acc,'ShippingStreet')[1];
        totalOld += levenshteinGetDistanceAccountMediaGetField(acc,'ShippingPostalCode')[0];
        totalNew += levenshteinGetDistanceAccountMediaGetField(acc,'ShippingPostalCode')[1];
        totalOld += levenshteinGetDistanceAccountMediaGetField(acc,'ShippingCity')[0];
        totalNew += levenshteinGetDistanceAccountMediaGetField(acc,'ShippingCity')[1];
        
        System.debug('-- JCAR -- levenshteinGetDistanceAccountMedia totalOld ' + totalOld);
        System.debug('-- JCAR -- levenshteinGetDistanceAccountMedia totalNew ' + totalNew);
        
        acc.KS_Levenshtein_Distance__c = 
            KS_LevenshteinDistance_Utils.levenshteinGetPercentageDistance(totalOld, totalNew);
        
        System.debug('-- JCAR -- levenshteinGetDistanceAccountMedia KS_Levenshtein_Distance__c ' + acc.KS_Levenshtein_Distance__c);
        return acc;
    }
    public static List<String> levenshteinGetDistanceAccountMediaGetField(Account acc, String field) {
        
        String totalOld = ''; String totalNew = '';
        List<String> val = new List<String>();
        String oldField = field;
        String newField = 'KS_'+field+'__c';
        String difField = 'KS_'+field+(field.contains('Street')?'_Complete_diff__c':'_diff__c');
        
        if (acc.get(difField) != null && (Decimal)acc.get(difField) > 0) {
            totalOld += acc.get(oldField) != null && (String)acc.get(oldField) != '' ? (String)acc.get(oldField) : '';
            totalNew += acc.get(newField) != null && (String)acc.get(newField) != '' ? (String)acc.get(newField) : '';
        }
        
        return new List<String>{totalOld,totalNew};
    }
    
    public static Decimal levenshteinGetDistance(sObject obj, String oldField, String newField) {

        System.debug('-- JCAR -- levenshteinGetDistance oldField ' + obj.get(oldField));
        System.debug('-- JCAR -- levenshteinGetDistance newField ' + obj.get(newField));
        
        if (obj == null) { return 0; }
        if (obj.get(oldField) == null && obj.get(newField) != null) { return 100; }
        if (obj.get(oldField) == null && obj.get(newField) == null) { return 0; }
        if (obj.get(newField) == null) { return 0; }
        if ((String)obj.get(newField) == '') { return 0; }
        
        return KS_LevenshteinDistance_Utils.levenshteinGetPercentageDistance((String)obj.get(oldField), (String)obj.get(newField));
    }
    
    public static Account setDirecciones(Account oldAcc) {
        
        Account newAcc = new Account();
        
        if (oldAcc==null) {return newAcc;}
        newAcc.BillingCity = oldAcc.BillingCity;
        newAcc.BillingPostalCode = oldAcc.BillingPostalCode;      
        newAcc.BillingStreet = oldAcc.BillingStreet;
        newAcc.KS_BillingCity__c = oldAcc.KS_Ciudad__c;
        newAcc.KS_BillingPostalCode__c = oldAcc.KS_C_digo_Postal__c;
        newAcc.ShippingCity = oldAcc.ShippingCity;
        newAcc.ShippingPostalCode = oldAcc.ShippingPostalCode;
        newAcc.ShippingStreet = oldAcc.ShippingStreet;
        newAcc.KS_ShippingCity__c = oldAcc.KS_Ciudad__c;
        newAcc.KS_ShippingPostalCode__c = oldAcc.KS_C_digo_Postal__c;
        
        newAcc.KS_Ciudad__c = oldAcc.KS_Ciudad__c;
        newAcc.KS_C_digo_Postal__c = oldAcc.KS_C_digo_Postal__c;
        newAcc.KS_Tipo_de_via__c = oldAcc.KS_Tipo_de_via__c;
        newAcc.KS_Calle__c = oldAcc.KS_Calle__c;
        newAcc.KS_N_m_portal_piso_puerta_y_resto_de_di__c = oldAcc.KS_N_m_portal_piso_puerta_y_resto_de_di__c;
        
        newAcc.KS_BillingStreet__c = '';
        newAcc.KS_ShippingStreet__c = '';
        if (stringNotNull(oldAcc.KS_Tipo_de_via__c)) {
            newAcc.KS_BillingStreet__c += oldAcc.KS_Tipo_de_via__c;
            newAcc.KS_ShippingStreet__c += oldAcc.KS_Tipo_de_via__c;
        }
        if (stringNotNull(oldAcc.KS_Calle__c)) {
            newAcc.KS_BillingStreet__c += (stringNotNull(newAcc.KS_BillingStreet__c)? ' ' : '') + oldAcc.KS_Calle__c;
            newAcc.KS_ShippingStreet__c += (stringNotNull(newAcc.KS_ShippingStreet__c)? ' ' : '') + oldAcc.KS_Calle__c;
        }
        if (stringNotNull(oldAcc.KS_N_m_portal_piso_puerta_y_resto_de_di__c)) {
            newAcc.KS_BillingStreet__c += (stringNotNull(newAcc.KS_BillingStreet__c)? ', ' : '') + oldAcc.KS_N_m_portal_piso_puerta_y_resto_de_di__c;
            newAcc.KS_ShippingStreet__c += (stringNotNull(newAcc.KS_ShippingStreet__c)? ', ' : '') + oldAcc.KS_N_m_portal_piso_puerta_y_resto_de_di__c;
        }
        return newAcc;
    }
    
    public static Boolean stringNotNull(String s) {
        return s != null && s.normalizeSpace().trim() != '';
    }
    
    public class Cuenta {
        public Account data {get;set;}
        public Cuenta(Account acc) {
            data = new Account(ID=acc.ID);
            
            data.Name = acc.Name;
            data.Phone = acc.Phone;
            data.KS_N_de_telefono_2__c = acc.KS_N_de_telefono_2__c;
            data.KS_N_de_telefono_3__c = acc.KS_N_de_telefono_3__c;
            
            data.BillingCity = acc.BillingCity;
            data.BillingPostalCode = acc.BillingPostalCode;      
            data.BillingStreet = acc.BillingStreet;
            data.ShippingCity = acc.ShippingCity;
            data.ShippingPostalCode = acc.ShippingPostalCode;
            data.ShippingStreet = acc.ShippingStreet;
            
            data.KS_BillingCity__c = acc.KS_BillingCity__c;
            data.KS_BillingPostalCode__c = acc.KS_BillingPostalCode__c;      
            data.KS_BillingStreet__c = acc.KS_BillingStreet__c;
            data.KS_ShippingCity__c = acc.KS_ShippingCity__c;
            data.KS_ShippingPostalCode__c = acc.KS_ShippingPostalCode__c;
            data.KS_ShippingStreet__c = acc.KS_ShippingStreet__c;
            
            data.KS_Ciudad__c = acc.KS_Ciudad__c;
            data.KS_C_digo_Postal__c = acc.KS_C_digo_Postal__c;
            data.KS_Tipo_de_via__c = acc.KS_Tipo_de_via__c;
            data.KS_Calle__c = acc.KS_Calle__c;
            data.KS_N_m_portal_piso_puerta_y_resto_de_di__c = acc.KS_N_m_portal_piso_puerta_y_resto_de_di__c;
            
            System.debug('-- -- JCAR -- new Account wrapper ' + data);
        }
        
        public void setDiff() {
            data.KS_BillingCity_Diff__c = levenshteinGetDistance(data, 'BillingCity', 'KS_Ciudad__c');
            data.KS_BillingPostalCode_Diff__c = levenshteinGetDistance(data, 'BillingPostalCode', 'KS_C_digo_Postal__c');
            
            String billingStreet = '';
            if (stringNotNull(data.KS_Calle__c)) {
                billingStreet += data.KS_Calle__c;
            }
            if (stringNotNull(data.KS_N_m_portal_piso_puerta_y_resto_de_di__c)) {
                billingStreet += (stringNotNull(billingStreet)? ', ' : '') + data.KS_N_m_portal_piso_puerta_y_resto_de_di__c;
            }
            
            data.KS_BillingStreet_Diff__c =  
                KS_LevenshteinDistance_Utils.levenshteinGetPercentageDistance(data.BillingStreet, billingStreet);
            
            if (stringNotNull(data.KS_Tipo_de_via__c)) {
                billingStreet = data.KS_Tipo_de_via__c + (stringNotNull(billingStreet)? ' ' + billingStreet : '');
            }
            
            data.KS_BillingStreet_Complete_Diff__c =  
                KS_LevenshteinDistance_Utils.levenshteinGetPercentageDistance(data.BillingStreet, billingStreet);
        }
    }
}