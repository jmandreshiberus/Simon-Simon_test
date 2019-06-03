global without sharing class KS_Debug_Utils {
    
    public static Map<String,RecordType> mapRecordType() {
        Map<String,RecordType> mapa = new Map<String,RecordType>();
        for (RecordType rt : [SELECT DeveloperName, Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'KS_Debug__c']) {
            mapa.put(rt.DeveloperName, rt);
        }
        return mapa;
    }
    
    public static Map<String,String> mapCampos() {
        Map<String,String> campos = new Map<String,String>();
        
        // CUENTA
        campos.put('BillingStreet', 'KS_Merge_Calle__c');
        campos.put('BillingCity', 'KS_Merge_Ciudad__c');
        campos.put('BillingPostalCode', 'KS_Merge_CodPostal__c');
        campos.put('BillingState', 'KS_Merge_Provincia__c');
        campos.put('BillingCountryCode', 'KS_Merge_CodPais__c');
        campos.put('Phone', 'KS_Merge_Telf1__c');
        campos.put('KS_N_de_telefono_2__c', 'KS_Merge_Telf2__c');
        campos.put('KS_N_de_telefono_3__c', 'KS_Merge_Telf3__c');
        campos.put('KS_Email__c', 'KS_Merge_Email__c');
        campos.put('KS_Canal__c', 'KS_Merge_Canal__c');
        campos.put('KS_Actividad__c', 'KS_Merge_Actividad__c');
        campos.put('KS_Subactividad__c', 'KS_Merge_Subactividad__c');
        campos.put('KS_Sector__c', 'KS_Merge_Sector__c');
        
        // CONTACTO
        campos.put('OtherStreet', 'KS_Merge_Calle__c');
        campos.put('OtherCity', 'KS_Merge_Ciudad__c');
        campos.put('OtherPostalCode', 'KS_Merge_CodPostal__c');
        campos.put('OtherState', 'KS_Merge_Provincia__c');
        campos.put('OtherCountry', 'KS_Merge_CodPais__c');
        //campos.put('Phone', 'KS_Merge_Telf1__c');
        campos.put('MobilePhone', 'KS_Merge_Telf2__c');
        campos.put('HomePhone', 'KS_Merge_Telf3__c');
        campos.put('Email', 'KS_Merge_Email__c');
        campos.put('KS_Funcion_en_empresa__c', 'KS_Merge_Funcion__c');
        campos.put('KS_Idioma__c', 'KS_Merge_Idioma__c');
        
        // MARCA
        campos.put('KS_Scoring_Actividad__c', 'KS_Merge_ScoringA__c');
        campos.put('KS_Scoring_Negocio__c', 'KS_Merge_ScoringN__c');
        campos.put('KS_Scoring_IF__c', 'KS_Merge_ScoringIF__c');
        campos.put('KS_Recurrencia__c', 'KS_Merge_Recurrencia__c');
        //campos.put('Owner.Name', 'KS_Merge_Responsable__c'); esto no funciona
        
        //campos.put('Owner.Username', 'KS_Master_Owner__c'); esto no funciona
        
        return campos;
    }
    
    public static KS_Debug__c newFusionDebug(String cls, String apx, String mtd, String cod) {
        KS_Debug__c debug = new KS_Debug__c();
        debug.KS_Clase__c = cls;
        debug.KS_Origen__c = apx;
        debug.KS_Origen_Metodo__c = mtd;
        debug.KS_Codigo__c = cod;
        return debug;
    }
    public static KS_Debug__c newFusionDebugDesc(String cls, String apx, String mtd, String dsc, String cod) {
        KS_Debug__c debug = newFusionDebug(cls, apx, mtd, cod);
        debug.KS_Descripcion__c = dsc;
        return debug;
    }
    
    public static KS_Debug__c debugField(String cls, String apx, String mtd, String objID, String cmp, String vlr, String keyField, List<SObject> sObjLst) {
        Map<String,String> valores = new Map<String,String>();
        for (SObject obj : sObjLst) {
            if (obj != null && obj.get(cmp) != null) { valores.put((String)obj.get(keyField), (String)obj.get(cmp)); }
        }
        return KS_Debug_Utils.debugFieldDesc(cls, apx, mtd, objID, cmp, vlr, valores);
    }
    public static KS_Debug__c debugFieldDesc(String cls, String apx, String mtd, String objID, String cmp, String vlr, Map<String,String> antiguosValores) {
        KS_Debug__c debug = KS_Debug_Utils.newFusionDebug(cls, apx, mtd, objID);
        debug.KS_Campo__c = cmp;
        debug.KS_Descripcion__c = null;
        for (String valorK : antiguosValores.keySet()) {
            debug.KS_Descripcion__c += debug.KS_Descripcion__c != null ? '\r\n' : '';
            debug.KS_Descripcion__c += valorK + ' - Antiguo Valor: ' + antiguosValores.get(valorK);
        }
        debug.KS_Descripcion__c += debug.KS_Descripcion__c != null ? '\r\n\r\n' : '';
        debug.KS_Descripcion__c += 'NUEVO VALOR: ' + vlr;
        return debug;
    }
    
    // cls = clase apex que llama
    // mtd = metodo apex que llama
    // objID = id/código objeto depurado
    // keyfield = nombre de campo identificativo del objeto
    // obj = objeto con el nuevo valor asignado
    // sObjLst = lista de objetos de los que hace falta histórico de valores (puede ser más de uno), puede ser null o estar vacío
    // campos = mapeo nombre campos <obj, sObjLst.get()>
    public static KS_Debug__c debugObjectFieldsLst(String cls, String apx, String mtd, String objID, String keyField, SObject obj, List<SObject> sObjLst, Map<String, String> campos) {
        
        Map<String,String> mapCampos = KS_Debug_Utils.mapCampos();
        KS_Debug__c debug = KS_Debug_Utils.newFusionDebug(cls, apx, mtd, objID);
        
        // Se creará un objeto fusión por cada duplicado
        // se guardará el valor original de tanto el principal como el duplicado
        // todo en campos String, se separará ambos valores por una ; y un >, o sea: valor1 ; valor2 ; valor3 > valorNuevo
        for(String campoLog : campos.keySet()) {
            //if ( KS_Debug_Utils.campoNotFull(campoLog, obj) ) { // verificamos los campos
                String valor = null;
                if (sObjLst != null && !sObjLst.isEmpty()) {
                    
                    for (SObject sObj : sObjLst) {
                        valor = (valor != null ? valor+' ; ' : '');
                        valor += (KS_Debug_Utils.campoNotFull(campos.get(campoLog), sObj)? (String)sObj.get(campos.get(campoLog)) : 'NULL');
                    }
                    valor += KS_Debug_Utils.campoNotFull(campoLog, obj)? ' > ' + (String)obj.get(campoLog) : '';
                    
                } else {
                    valor = KS_Debug_Utils.campoNotFull(campoLog, obj)? (String)obj.get(campoLog) : '';
                }
                
                if (mapCampos.containsKey(campos.get(campoLog))) {
                    String campoDebug = mapCampos.get(campos.get(campoLog));
                    ((sObject)debug).put(campoDebug, valor);
                }
            //}
        }

        return debug;
    }
    public static Boolean campoNotFull(String campo, SObject obj) {
        return obj.get(campo) != null && ((String)obj.get(campo) != '');
    }
    
    public static List<KS_Debug__c> processSaveResult(
        List<Database.SaveResult> saveResult, Map<String,sObject> data, String origenClass, String origenMethod) {
            
            System.debug('-- -- -- processSaveResult ' + origenClass + '.' + origenMethod);
            
            ID rT = mapRecordType().get('KS_DEBUG_ERROR').ID;
            List<KS_Debug__c> insertDebug = new List<KS_Debug__c>();
            
            Integer index = 0;
            for (Database.SaveResult sR : saveResult) {
                
                sObject sobj = data.values().get(index);
                System.debug('-- -- -- processSaveResult sObject ' + sobj + ' isSuccess? ' + sR.isSuccess());
                if (!sR.isSuccess()) {
                    KS_Debug__c debug = new KS_Debug__c(RecordTypeId=rT);
                    debug.KS_Codigo__c = sobj.ID;
                    String textError = '';
                    debug.KS_Campo__c = '';
                    for (Database.Error err : sR.getErrors()) {
                        textError += ' ## ' + err.getMessage();
                        debug.KS_Campo__c += String.join(err.getFields(), ' '); 
                    }
                    debug.KS_Descripcion__c = textError;
                    debug.KS_Clase__c = sobj.getSObjectType().getDescribe().getName();
                    debug.KS_Origen__c = origenClass;
                    debug.KS_Origen_Metodo__c = origenMethod;
                    insertDebug.add(debug);
                }
                index++;
            }
            if (!insertDebug.isEmpty()) { 
                System.debug('-- -- -- processSaveResult List<KS_Debug__c> ' + insertDebug.size() + ' - ' + insertDebug);
                insert insertDebug;
            } else {
                System.debug('-- -- -- processSaveResult NO ERRORS');
            }
            
            return insertDebug;
        }
}