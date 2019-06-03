public without sharing class KS_Obra_Trigger extends KS_TriggerController {

    public KS_Obra_Trigger (Boolean isAfter, Boolean isBefore, Boolean isDelete, Boolean isInsert, Boolean isUndelete, Boolean isUpdate,
        List<sObject> lstNewItems, Map<Id, sObject> mapNewItems, List<sObject> lstOldItems, Map<Id, sObject> mapOldItems)
    {
        super(isAfter, isBefore, isDelete, isInsert, isUndelete, isUpdate, lstNewItems, mapNewItems, lstOldItems, mapOldItems);
    }
    
    public static Map<ID,sObject> running = new Map<ID,sObject>();
    public static Boolean isBlocked() { System.debug('-- TRIGGER BLOCKED! --'); return Test.isRunningTest() && KS_Trigger_Test.blockTrigger; }
    public static Boolean isRunning(Map<Id, sObject> items) {
        // 2018/10/16 JCAR Control recursividad
        items = items != null ? items : new Map<ID,SObject>();
        if (running == null) { running = new Map<ID,sObject>(); }
        if(!running.isEmpty()) {return true;}
        if (items != null && running != null) { running.putAll(items); }
        return false;
    }
    
    //protected override void runBeforeInsert(){ executeBeforeUpsert(); }
    //protected override void runBeforeUpdate(){ executeBeforeUpsert(); }
    //public void executeBeforeUpsert(){ setUbicacionObra(); }
    
    protected override void runAfterInsert(){ if(isBlocked()){return;} setUbicacionObra(); }
    protected override void runAfterUpdate(){ if(isBlocked()||isRunning(mapNewItems)){return;} executeAfterUpdate(); setUbicacionObra(); }
    public void executeAfterUpdate() {
        
        List<KS_Obra__c> obraLst = (List<KS_Obra__c>)lstNewItems;
        List<KS_Obra__c> obraLstOLD = isInsert ? new List<KS_Obra__c>() : (List<KS_Obra__c>)lstOldItems;
        
        List<ID> obrasChangeEstado = new List<ID>();
        Map<ID, String> obrasEstados = new Map<ID, String>();
        
        for (Integer i = 0; i < obraLst.size(); i++) {
            
            KS_Obra__c obra = obraLst.get(i);
            KS_Obra__c obraOLD = isInsert ? new KS_Obra__c() : obraLstOLD.get(i);
            
            // Cambio de estado           
            if (obra.KS_Fase__c != obraOLD.KS_Fase__c) {
                obrasChangeEstado.add(obra.ID);
                obrasEstados.put(obra.ID, obra.KS_Fase__c);
            }
        }
        
        // Mapeo ofertas obras
        if (obrasChangeEstado.size()>0) {
            
            List<Opportunity> ofertasUpdate = new List<Opportunity>();
            List<Opportunity> ofertas =  [SELECT ID,StageName,KS_Obra__c FROM Opportunity
                                          WHERE KS_Obra__c in :obrasChangeEstado];
            
            for (Opportunity oferta : ofertas) {
                
                String estado = oferta.StageName;
                String estadoObra = obrasEstados.get(oferta.KS_Obra__c);
                
                if (estadoObra == 'Parada' && estado != estadoObra) {
                    oferta.StageName = estadoObra;
                    if (KS_Opportunity_Trigger.runningOpps != null && !KS_Opportunity_Trigger.runningOpps.containsKey(oferta.ID)) { // 2018/10/16 JCAR Control recursividad
                        ofertasUpdate.add(oferta);
                    } else {
                        // 2018/10/16 JCAR Control recursividad
                        KS_Opportunity_Trigger.runningOpps = KS_Opportunity_Trigger.runningOpps != null ? KS_Opportunity_Trigger.runningOpps : new Map<ID,sObject>();
                        KS_Opportunity_Trigger.runningOpps.put(oferta.ID, oferta);
                    }
                }
            }

            if (ofertasUpdate.size()>0) { update ofertasUpdate; }
        }
    }
    
    public void setUbicacionObra() {
        
        Map<String,ID> terrType = new Map<String,ID>();
        List<Territory2Type> terrLst = [SELECT ID, DeveloperName FROM Territory2Type];
        for (Territory2Type tp : terrLst) {
            terrType.put(tp.DeveloperName, tp.ID);
        }
        
        Map<String,ID> recordTypes = new Map<String,ID>();
        List<RecordType> rtLst = [SELECT ID,DeveloperName FROM RecordType];
        for (RecordType rt : rtLst) {
            recordTypes.put(rt.DeveloperName, rt.ID);
        }        
        
        List<KS_Obra__c> obraLst = (List<KS_Obra__c>)lstNewItems;
        List<KS_Obra__c> obraLstOLD = isInsert ? new List<KS_Obra__c>() : (List<KS_Obra__c>)lstOldItems;
        
        Map<ID, Set<String>> obraMarcas = new Map<ID, Set<String>>();
        Map<ID, String> obraPais = new Map<ID, String>();
        Map<ID, String> obraCodPos = new Map<ID, String>();
        Set<String> idMarcaSet = new Set<String>(); List<String> idMarcaLst = new List<String>();
        
        List<ID> resetMarcas = new List<ID>();
        
        for (Integer i = 0; i < obraLst.size(); i++) {

            KS_Obra__c obra = obraLst.get(i);
            KS_Obra__c obraOLD = isInsert ? new KS_Obra__c() : obraLstOLD.get(i);          
            
            Boolean direccionOportunidad = obra.KS_Codigo_postal_oportunidad__c != null && obra.KS_Pais_oportunidad__c != null;
            Boolean direccionOportunidadOLD = obraOLD.KS_Codigo_postal_oportunidad__c != null && obraOLD.KS_Pais_oportunidad__c != null;
            
            String codP = direccionOportunidad ? obra.KS_Codigo_postal_oportunidad__c : obra.KS_Codigo_Postal__c;
            String pais = direccionOportunidad ? obra.KS_Pais_oportunidad__c : obra.KS_Pais__c;      
            String codPOLD = direccionOportunidadOLD ? obraOLD.KS_Codigo_postal_oportunidad__c : obraOLD.KS_Codigo_Postal__c;
            String paisOLD = direccionOportunidadOLD ? obraOLD.KS_Pais_oportunidad__c : obraOLD.KS_Pais__c;            
            
            Boolean newRT = obraOLD.RecordTypeId == recordTypes.get('KS_Construdatos') && obra.RecordTypeId == recordTypes.get('KS_Oportunidades');
            
            /*if (obra.KS_Marca__c == null) {
                if (obra.KS_hasSimon__c) { obra.KS_Marca__c = 'SI10'; }
                else if (obra.KS_hasFluvia__c) { obra.KS_Marca__c = 'FL31'; }
                else if (obra.KS_hasLighting__c) { obra.KS_Marca__c = 'IE20'; }                
            }*/
            
            if ( (obraOLD.KS_Marca__c == null && obra.KS_Marca__c != null) || isInsert 
                || (codPOLD == null && codP != null) ) {

                Set<String> marcas = new Set<String>();
                if (obraMarcas.containsKey(obra.ID)) { marcas = obraMarcas.get(obra.ID); }
                marcas.add(obra.KS_Marca__c);
                
                obraMarcas.put(obra.ID, marcas);
                idMarcaSet.add(obra.KS_Marca__c);
                    
                if (codP != null) {
                    obraCodPos.put(obra.ID, codP);
                }
                    
                if (pais != null) {
                    obraPais.put(obra.ID, pais);
                }                    
            }

            if (isUpdate && ( newRT || obra.KS_Ubicaciones_COUNT__c == 0 || (codP != codPOLD || obra.KS_Marca__c != obraOLD.KS_Marca__c || pais != paisOLD) ) ) {
                
                resetMarcas.add(obra.ID);
                Set<String> marcas = new Set<String>();
                if (obraMarcas.containsKey(obra.ID)) { marcas = obraMarcas.get(obra.ID); }                
                
                if (obra.KS_Marca__c != null) { idMarcaSet.add(obra.KS_Marca__c); marcas.add(obra.KS_Marca__c); }
                if (obra.KS_hasSimon__c) { idMarcaSet.add('SI10'); marcas.add('SI10'); }
                if (obra.KS_hasFluvia__c) { idMarcaSet.add('FL31'); marcas.add('FL31'); }
                if (obra.KS_hasLighting__c) { idMarcaSet.add('IE20'); marcas.add('IE20'); }

                obraMarcas.put(obra.ID, marcas);
                obraCodPos.put(obra.ID, codP);
                obraPais.put(obra.ID, pais);
            
            } else if (isUpdate) {
                
                Set<String> marcas = new Set<String>();
                if (obraMarcas.containsKey(obra.ID)) { marcas = obraMarcas.get(obra.ID); }                 
                
                if (obra.KS_hasSimon__c && !obraOLD.KS_hasSimon__c) 
                { idMarcaSet.add('SI10'); marcas.add('SI10'); }
                else if(!obra.KS_hasSimon__c && obraOLD.KS_hasSimon__c) 
                { resetMarcas.add(obra.ID); }
                
                if (obra.KS_hasFluvia__c && !obraOLD.KS_hasFluvia__c) 
                { idMarcaSet.add('FL31'); marcas.add('FL31'); }
                else if(!obra.KS_hasFluvia__c && obraOLD.KS_hasFluvia__c) 
                { resetMarcas.add(obra.ID); }
                
                if (obra.KS_hasLighting__c && !obraOLD.KS_hasLighting__c) 
                { idMarcaSet.add('IE20'); marcas.add('IE20'); }
                else if(!obra.KS_hasLighting__c && obraOLD.KS_hasLighting__c) 
                { resetMarcas.add(obra.ID); }
                
                if (marcas.size()>0) {
                    obraMarcas.put(obra.ID, marcas);
                    obraCodPos.put(obra.ID, codP);
                    obraPais.put(obra.ID, pais);
                }
            }
        }

        System.debug('-- JCAR ---------------------------------- - setUbicacionObra ' + resetMarcas.size() + ' resetMarcas - ' + resetMarcas);
        if (resetMarcas.size()>0) {
            //KS_Obra_Ubicacion__c
            List<KS_Obra_Ubicacion__c> obuDEL = [SELECT ID FROM KS_Obra_Ubicacion__c WHERE KS_Obra__c IN :resetMarcas];
            System.debug('-- JCAR ---------------------------------- - setUbicacionObra ' + obuDEL.size() + ' DELETE KS_Obra_Ubicacion__c  - ' + obuDEL);
            delete obuDEL;
        }
        
		System.debug('-- JCAR ---------------------------------- - setUbicacionObra ' + obraMarcas.size() + ' obraMarcas - ' + obraMarcas);
        System.debug('-- JCAR ---------------------------------- - setUbicacionObra ' + obraCodPos.size() + ' obraCodPos - ' + obraCodPos);
        System.debug('-- JCAR ---------------------------------- - setUbicacionObra ' + obraPais.size() + ' obraPais - ' + obraPais);
        
        idMarcaLst.addAll(idMarcaSet);
        List<KS_Estructura_Geografica__c> esGeogLst = 
            [SELECT Id, KS_CPDesde__c, KS_CPHasta__c, KS_Delegacion__c, KS_Area__c, KS_Zona__c, KS_Organizacion_de_ventas__c, KS_CountryCode__c 
             FROM KS_Estructura_Geografica__c WHERE KS_Organizacion_de_ventas__c IN :idMarcaLst AND KS_CountryCode__c IN : obraPais.values()];
        
        Map<ID, Set<ID>> ubicacionObraMap = new Map<ID, Set<ID>>();
        Map<String, String> marcareaUbicacion = new Map<String, String>();
        
        List<String> areaGLst = new List<String>();
        List<String> orgVnLST = new List<String>();
        
        // Supondremos que las obras siempre son en España
        for (ID obraID : obraCodPos.keySet()) {
            
            String codPostal = obraCodPos.get(obraID);
            Set<String> marcas = obraMarcas.get(obraID);
            String pais = obraPais.get(obraID);
            
            System.debug('-- JCAR ---------------------------------- - for OBRA ' + obraID);
            System.debug('-- JCAR ---------------------------------- - for OBRA codPostal ' + codPostal);
            System.debug('-- JCAR ---------------------------------- - for OBRA marcas ' + marcas);
            
            for (KS_Estructura_Geografica__c eg : esGeogLst) {
                
                Boolean bingo = false;
                if (marcas.contains(eg.KS_Organizacion_de_ventas__c) && eg.KS_CountryCode__c == pais && eg.KS_CPDesde__c != null) {
                    
                    String dsd = eg.KS_CPDesde__c;
                    String hst = eg.KS_CPHasta__c;
                    
                    if (codPostal.length() == 4) { 
                        codPostal = '0'+codPostal;
                    }
                    bingo = codPostal.startsWithIgnoreCase(dsd.substring(0,2));                    
                }
                if (bingo && eg.KS_Area__c != null && eg.KS_Organizacion_de_ventas__c != null) {
                    
                    System.debug('-- JCAR ---------------------------------- - for OBRA BINGO');
                    System.debug('-- JCAR ---------------------------------- - for OBRA ' + eg);
                    
                    Set<ID> egIDs = new Set<ID>();
                    if (ubicacionObraMap.containsKey(obraID)) { egIDs = ubicacionObraMap.get(obraID); }
                    egIDs.add(eg.ID); ubicacionObraMap.put(obraID, egIDs);
                    
                    areaGLst.add(eg.KS_Area__c);
                    orgVnLST.add(eg.KS_Organizacion_de_ventas__c);
                    //break;

                    String uboK = obraID + '-' + eg.ID;
                    String uboV = eg.KS_Organizacion_de_ventas__c + '-' + eg.KS_Area__c;
                    marcareaUbicacion.put(uboK, uboV);
                }
            }
        }
        
        System.debug('-- JCAR ---------------------------------- - setUbicacionObra ' + ubicacionObraMap.size() + ' ubicacionObraMap - ' + ubicacionObraMap);
        System.debug('-- JCAR ---------------------------------- - setUbicacionObra ' + marcareaUbicacion.size() + ' marcareaUbicacion - ' + marcareaUbicacion);
        
        System.debug('-- JCAR ---------------------------------- - setUbicacionObra ' + areaGLst.size() + ' areaGLst - ' + areaGLst);
        System.debug('-- JCAR ---------------------------------- - setUbicacionObra ' + orgVnLST.size() + ' orgVnLST - ' + orgVnLST);
        
        //List<KS_Obra_Ubicacion__c> ubacionesObra = new List<KS_Obra_Ubicacion__c>();
        Map<String, KS_Obra_Ubicacion__c> ubacionesObra = new Map<String, KS_Obra_Ubicacion__c>();
        for (ID obraID : ubicacionObraMap.keySet()) {

            Set<ID> egID = ubicacionObraMap.get(obraID);
            for (ID eg : egID) {
                
                if (eg != null) {
                    KS_Obra_Ubicacion__c ubo = new KS_Obra_Ubicacion__c();
                    ubo.KS_Obra__c = obraID;
                    ubo.KS_Ubicacion__c = eg;
                    ubo.KS_ID__c = ubo.KS_Obra__c + '-' + ubo.KS_Ubicacion__c;
                    
                    ubacionesObra.put(ubo.KS_ID__c, ubo);
                }
            }
        }
        
        Map<ID,ID> responsables = new Map<ID,ID>();
        List<UserTerritory2Association> terrOferta = 
            [SELECT Id, UserId, Territory2Id, RoleInTerritory2,
             Territory2.KS_Organizacion_Ventas__c,
             Territory2.KS_Area__c
             FROM UserTerritory2Association 
             WHERE RoleInTerritory2 = 'JAR'
             AND Territory2.KS_Organizacion_Ventas__c IN :orgVnLST
             AND Territory2.KS_Area__c IN :areaGLst
             AND Territory2.Territory2TypeId = :terrType.get('KS_Area')
            ];
        
        System.debug('-- JCAR ---------------------------------- - setUbicacionObra ' + terrOferta.size() + ' terrOferta - ' + terrOferta);
        
        for (String uoK : ubacionesObra.keySet()) {
            
            KS_Obra_Ubicacion__c ubo = ubacionesObra.get(uoK);
            for (UserTerritory2Association uta : terrOferta) {
                
                String ovTerr = uta.Territory2.KS_Organizacion_Ventas__c;
                String arTerr = uta.Territory2.KS_Area__c;
                ID usTerr = uta.UserId;
                
                //System.debug('-- JCAR ---------------------------------- - setUbicacionObra - SET JAR eg - org.vent ' + ovTerr + ' - area ' + arTerr + ' - user ' + usTerr);
                
                if (usTerr != null && ovTerr != null && arTerr != null && marcareaUbicacion.containsKey(uoK)) {
                    
                    String marcarea = marcareaUbicacion.get(uoK);
                    String ovMA = marcarea.split('-')[0];
                    String arMA = marcarea.split('-')[1]; 
                    
                    //System.debug('-- JCAR ---------------------------------- - setUbicacionObra - SET JAR ma - org.vent ' + ovMA + ' - area ' + arMA);
                    
                    if (ovTerr == ovMA && arTerr == arMA ) {
                        
                        ubo.KS_Responsable__c = usTerr;
                        ubacionesObra.put(uoK, ubo);
                    }
                }
            }
        }
        
        System.debug('-- JCAR ---------------------------------- - setUbicacionObra ' + ubacionesObra.size() + ' ubacionesObra - ' + ubacionesObra.values());
        
        Schema.DescribeFieldResult field = KS_Obra_Ubicacion__c.KS_ID__c.getDescribe();
        Schema.sObjectField idUbOb = field.getSObjectField();
        Database.UpsertResult[] upsertResult = Database.upsert(ubacionesObra.values(), idUbOb, true);         
    }    
}