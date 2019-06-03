public without sharing class KS_Opportunity_Trigger extends KS_TriggerController {

    public KS_Opportunity_Trigger (Boolean isAfter, Boolean isBefore, Boolean isDelete, Boolean isInsert, Boolean isUndelete, Boolean isUpdate,
        List<sObject> lstNewItems, Map<Id, sObject> mapNewItems, List<sObject> lstOldItems, Map<Id, sObject> mapOldItems)
    {
        super(isAfter, isBefore, isDelete, isInsert, isUndelete, isUpdate, lstNewItems, mapNewItems, lstOldItems, mapOldItems);
    }
    
    public static Map<ID,sObject> runningOpps = new Map<ID,sObject>();
    public static Boolean blocked() { System.debug('-- TRIGGER BLOCKED! --'); return Test.isRunningTest() && KS_Trigger_Test.blockTrigger; }
    
    protected override void  runBeforeInsert(){ if(blocked()){return;} executeBeforeInsert(); }
    protected override void  runBeforeUpdate(){ if(blocked()){return;} executeBeforeUpdate(); }
    protected override void  runAfterInsert(){ if(blocked()){return;} executeAfterInsert(); }
    protected override void  runAfterUpdate(){ if(blocked()){return;} executeAfterUpdate(); }
    
    public void executeBeforeInsert() { executeBeforeUpsert(); setTerritory(); }//setUbicacionObra();}
    public void executeBeforeUpdate() { executeBeforeUpsert(); setTerritory(); executeDuplicate(); }//setUbicacionObra();}
    public void executeAfterInsert() { executeAfterUpsert(); }
    public void executeAfterUpdate() { executeAfterUpsert(); }
    
    public void executeBeforeUpsert() {
        //return;

        mapNewItems = mapNewItems != null ? mapNewItems : new Map<ID,SObject>();
        if (runningOpps == null) { runningOpps = new Map<ID,sObject>(); }
        if(!runningOpps.isEmpty()) {return;}
        if (mapNewItems != null && runningOpps != null) { runningOpps.putAll(mapNewItems); }
        
        System.debug('-- JCAR ---------------------------------- executeBeforeUpsert');
        
        Map<String,ID> recordTypes = new Map<String,ID>();
        List<RecordType> rtLst = [SELECT ID,DeveloperName FROM RecordType];
        for (RecordType rt : rtLst) {
            recordTypes.put(rt.DeveloperName, rt.ID);
        }
        
        Map<String, ID> accGenericas = new Map<String,ID>();
        //if (isInsert) {
        List<Account> accSIMON = [SELECT ID,KS_ID_SAP__c FROM Account WHERE KS_ID_SAP__c LIKE 'SIMON_%'];
        for (Account acc : accSIMON) {
            accGenericas.put(acc.KS_ID_SAP__c, acc.ID);
        }
        //}
        
        List<Opportunity> oppLst = (List<Opportunity>)lstNewItems;
        List<Opportunity> oppLstOLD = isInsert ? new List<Opportunity>() : (List<Opportunity>)lstOldItems;
        // TRIGGER CONTABILIZA
        // Tenemos una oferta, la cual una orgacliente y apunta a una obra
        // la oferta.orgacliente tiene una orgaventas (campo formula en oferta!)
        // por cada OBRA (oferta.obra) solamente puede haber una OFERTA con CONTABILIZA en un mismo ORGAVENTAS 

        // TRIGGER CONTABILIZA
        List<ID> idOfer = new List<ID>();
        List<ID> idObra = new List<ID>(); List<String> strOrgVent = new List<String>();
        List<ID> idCont = new List<ID>();
        // TRIGGER ORGANIZACIÓN VENTAS
        Map<ID, KS_Obra__c> obraUpdate = new Map<ID, KS_Obra__c>();
        Map<ID, Opportunity> ofertasObra = new Map<ID, Opportunity>();
        List<String> marcasOferta = new List<String>();        
        // TRIGGER DESCARTAR MARCA/OBRA
        Map<Id, Opportunity> oppClosed = new Map<Id, Opportunity>();
        Map<Id, Set<String>> oppClosedMarcaObra = new Map<Id, Set<String>>();  
        Map<ID, KS_Obra__c> obraChangeEstado = new Map<ID, KS_Obra__c>();  
        
        // SINCRONIZACIÓN
        Map<String,Opportunity> sincroClieFin = new Map<String,Opportunity>();
        Map<String,Opportunity> sincroInstala = new Map<String,Opportunity>();
        Map<String,Opportunity> sincroDistrib = new Map<String,Opportunity>();
        
        ///////////////////////// MAPEOS /////////////////////////////
        
        Boolean error = false;
        for (Integer i = 0; i < oppLst.size(); i++) {

            Opportunity opp = oppLst.get(i);
            Opportunity oppOLD = isInsert ? new Opportunity() : oppLstOLD.get(i);
           
            opp.AccountId = accGenericas.get('SIMON_ESP');
            
            Id obra = opp.KS_Obra__c;
            Boolean haveObra = obra != null;
            String marca = 
                (opp.KS_Canal__c != null ? opp.KS_Canal__c : '')
                + (opp.KS_Organizacion_de_ventas__c != null ? opp.KS_Organizacion_de_ventas__c : '')
                + (opp.KS_Agente_de_contabilizacion__c != null ? opp.KS_Agente_de_contabilizacion__c : '');
            Boolean haveMarca = marca != null && marca != '';
            
            if (opp.KS_Oferta_Origen_String__c != null && opp.KS_Oferta_Origen__c == null) {
                if (opp.ID != opp.KS_Oferta_Origen_String__c) {
                    
                    opp.KS_Oferta_Origen__c = opp.KS_Oferta_Origen_String__c;    
                }
            }
            
            if (opp.KS_probabilidad__c == null) { opp.KS_probabilidad__c = 50; }
            if (opp.StageName == null) { opp.StageName = 'Licitación'; }
            
            // TRIGGER ORGANIZACIÓN VENTAS
            if (haveMarca) {
                opp.KS_Organizacion__c = opp.KS_Organizacion_de_ventas__c;
            } 
            if (haveObra) {
                
                KS_Obra__c obraObj = new KS_Obra__c(); obraObj.ID = opp.KS_Obra__c;
                if (obraUpdate.containsKey(opp.KS_Obra__c)) 
                { obraObj = obraUpdate.get(opp.KS_Obra__c); }
                
                Boolean changeObra = opp.KS_Organizacion_de_ventas__c != oppOLD.KS_Organizacion_de_ventas__c;
                if (changeObra) { 
                    obraUpdate.put(obraObj.ID, obraObj);
                    ofertasObra.put(opp.ID, opp);
                }
                
                if (changeObra && oppOLD.KS_Organizacion_de_ventas__c == null) {
                    
                    if ( opp.RecordTypeId == recordTypes.get('KS_Oferta_cliente') ) 
                    { opp.RecordTypeId = recordTypes.get('KS_Oferta'); }
                    else if ( opp.RecordTypeId == recordTypes.get('Oferta_Export_Cliente') ) 
                    { opp.RecordTypeId = recordTypes.get('KS_Oferta_Export'); }
                }
            }
            
            if (opp.StageName == 'Adjudicada totalmente') {
                opp.KS_Probabilidad__c = 100;
            }
            
            if (haveObra) { idObra.add(opp.KS_Obra__c); }
            
            // TRIGGER DESCARTAR MARCA/OBRA
            if (isUpdate /*&& getClosed(opp)*/ && haveObra && haveMarca) {
                
                Set<String> marcasObra = new Set<String>();
                if ( oppClosedMarcaObra.containsKey(opp.KS_Obra__c) )
                { marcasObra = oppClosedMarcaObra.get(opp.KS_Obra__c); }
                marcasObra.add(marca); 
                oppClosedMarcaObra.put(obra, marcasObra);
                oppClosed.put(opp.ID, opp);
                marcasOferta.add(marca);
                
                if (getClosed(opp)) {
                    opp.KS_Contabiliza__c = true;
                }
            }
            
            Boolean contabiliza = opp.KS_Contabiliza__c;
            String contabilizador = opp.KS_Agente_de_contabilizacion__c;
            
            if (!contabiliza && contabilizador == null) { opp.KS_Sincronizacion__c = null; }
            
            if (contabiliza && contabilizador == null) {
                opp.addError('Error en oferta '+opp.Name+': Debe seleccionarse agente de contabilización.');
                error = true;
            }
        }

        if (error) {return;}
        
        //////////////////// LÓGICA //////////////////////
        
        System.debug('-- JCAR ---------------------------------- !oppClosedMarcaObra.isEmpty() '
                     + oppClosedMarcaObra);
        
        if (mapNewItems != null) { idOfer.addAll(mapNewItems.keySet()); }
        if (Test.isRunningTest()) { idOfer = new List<ID>(); }
        
        Map<ID,Opportunity> oppUpdate = new Map<ID,Opportunity>();
        List<Opportunity> oppObras = [SELECT ID, Name, KS_Canal__c,
                                      KS_Organizacion_de_ventas__c, KS_Organizacion__c,
                                      KS_Obra__c, StageName, KS_Contabiliza__c,
                                      KS_Agente_de_contabilizacion__c, KS_Sincronizacion__c
                                      FROM Opportunity WHERE KS_Obra__c IN :idObra 
                                      AND ID NOT IN :idOfer
                                      /*AND KS_Organizacion_de_ventas__c IN :marcasOferta*/
                                      /*AND KS_Contabiliza__c = false*/];
        
        if (Test.isRunningTest()) { idOfer.addAll(mapNewItems.keySet()); }
        
        System.debug('-- JCAR ---------------------------------- Opp.executeBeforeUpsert - ' + oppObras.size() + ' oppObras - ' + oppObras);

        Map<ID, Boolean> obraContabiliza = new Map<Id, Boolean>();
        Map<String, Boolean> obraContaAgente = new Map<String, Boolean>();
        
        Boolean noContabilizadoras = false;
        for (Opportunity opp : oppObras) {
            
            //if (mapNewItems.containsKey(opp.ID)) { continue; }
            
            String contabilizador = opp.KS_Agente_de_contabilizacion__c;
            if (opp.KS_Obra__c != null && opp.KS_Organizacion__c != null) {
                String sincroKey = opp.KS_Obra__c+opp.KS_Organizacion__c;
                opp.KS_Sincronizacion__c = null;
                if (contabilizador == 'Distribuidor') { sincroDistrib.put(sincroKey, opp); }
                else if (contabilizador == 'Instalador') { sincroInstala.put(sincroKey, opp); }
                else if (contabilizador == 'Cliente final') { sincroClieFin.put(sincroKey, opp); }
            }
            
            // TRIGGER DESCARTAR MARCA/OBRA
            if ( (isInsert&&isBefore) || !oppClosedMarcaObra.isEmpty()) {

                String kmarca = 
                    (opp.KS_Canal__c != null ? opp.KS_Canal__c : '')
                    + (opp.KS_Organizacion_de_ventas__c != null ? opp.KS_Organizacion_de_ventas__c : '') 
                    + (opp.KS_Agente_de_contabilizacion__c != null ? opp.KS_Agente_de_contabilizacion__c : '');
                
                if (opp.KS_Contabiliza__c && /*(getClosed(opp) || */!getDescarted(opp)/*)*/ )
                { obraContabiliza.put(opp.KS_Obra__c, true); obraContaAgente.put(opp.KS_Obra__c + kmarca, true); continue; }
                
                if (getClosed(opp)&&getDescarted(opp)) { continue; }
                
                Set<String> marcas = new Set<String>();
                if (oppClosedMarcaObra.containsKey(opp.KS_Obra__c))
                { marcas = oppClosedMarcaObra.get(opp.KS_Obra__c); }
                if (marcas.contains(kmarca/*opp.KS_Organizacion_de_ventas__c*/) && !opp.KS_Contabiliza__c)
                {
                    if ( runningOpps.containsKey(opp.ID) ) {
                        Opportunity oppFromMap = (Opportunity)runningOpps.get(opp.ID);
                        if (oppFromMap.KS_Contabiliza__c) {
                            oppFromMap.StageName = 'Adjudicada a otro Distribuidor';
                            oppFromMap.KS_Probabilidad__c = 0;
                        }
                    } else {
                        if (opp.KS_Contabiliza__c) {
                            opp.StageName = 'Adjudicada a otro Distribuidor';
                            opp.KS_Probabilidad__c = 0;
                            oppUpdate.put(opp.id,opp);
                        }
                    }
                }
                
                if ( opp.ID != null && mapNewItems.containsKey(opp.ID) ) {
                    Opportunity oppFromMap = (Opportunity)mapNewItems.get(opp.ID);
                    if (oppFromMap.StageName == 'Adjudicada totalmente') {
                        oppFromMap.KS_Probabilidad__c = 100;
                    }
                }
            }
        }
        
        System.debug('-- JCAR ---------------------------------- Opp.executeBeforeUpsert - ' 
                     + obraContaAgente.size() + ' obraContaAgente - ' + obraContaAgente);
        
        System.debug('-- JCAR ---------------------------------- Opp.executeBeforeUpsert - ' + sincroDistrib.size() + ' sincroDistrib - ' + sincroDistrib);
        System.debug('-- JCAR ---------------------------------- Opp.executeBeforeUpsert - ' + sincroInstala.size() + ' sincroInstala - ' + sincroInstala);
        System.debug('-- JCAR ---------------------------------- Opp.executeBeforeUpsert - ' + sincroClieFin.size() + ' sincroClieFin - ' + sincroClieFin);
        
        Boolean wrong = false;
        oppUpdate = calcSincronizacion(null, oppUpdate, obraContaAgente, sincroClieFin, sincroInstala, sincroDistrib);
        if (wrong) { return; }
        
        System.debug('-- JCAR ---------------------------------- Opp.executeBeforeUpsert - ' + sincroDistrib.size() + ' sincroDistrib - ' + sincroDistrib);
        System.debug('-- JCAR ---------------------------------- Opp.executeBeforeUpsert - ' + sincroInstala.size() + ' sincroInstala - ' + sincroInstala);
        System.debug('-- JCAR ---------------------------------- Opp.executeBeforeUpsert - ' + sincroClieFin.size() + ' sincroClieFin - ' + sincroClieFin);
        
        System.debug('-- JCAR ---------------------------------- Opp.executeBeforeUpsert - ' + oppUpdate.size() + ' oppUpdate - ' + oppUpdate);
        for (ID rID : runningOpps.keySet()) { oppUpdate.remove(rID); }
        update oppUpdate.values();
        
        System.debug('-- JCAR ---------------------------------- Opp.executeBeforeUpsert - ' + obraContabiliza.size() + ' obraContabiliza - ' + obraContabiliza);
        
        for (ID obraID : idObra) {
            
            if (!obraContabiliza.containsKey(obraID)) {
                
                KS_Obra__c obraOferta = new KS_Obra__c();
                obraOferta.ID = obraID;
                if (obraChangeEstado.containsKey(obraID))
                { obraOferta = obraChangeEstado.get(obraID); } 
                obraOferta.KS_Fase__c = 'Finalizada';
                obraChangeEstado.put(obraID, obraOferta);
            }
        }
        
        if (obraChangeEstado.size()>0) {
            update obraChangeEstado.values();
        }
        
        // TRIGGER PRICEBOOK
        setPriceBook();
        
        System.debug('-- JCAR ---------------------------------- Opp.executeBeforeUpsert - ' + obraUpdate.size() + ' obraUpdate - ' + obraUpdate);
        
        // TRIGGER ORGANIZACIÓN VENTAS
        if (obraUpdate.size()>0) {
            // Debemos recomprobar todas las ofertas de obras afectadas, por poco optimo que sea
            updateOrganizacionVentas(obraUpdate, ofertasObra);
        }
    }
    
    public class KSTriggerException extends Exception {}
    public Map<ID,Opportunity> calcSincronizacion(
        List<Opportunity> oppLst, 
        Map<ID,Opportunity> oppUpdate, Map<String, Boolean> obraContaAgente, 
        Map<String,Opportunity> sincroClieFin, Map<String,Opportunity> sincroInstala, Map<String,Opportunity> sincroDistrib) 
    {
        oppLst = oppLst != null ? oppLst : (List<Opportunity>)lstNewItems;
        for (Opportunity opp : oppLst) {
            Id obra = opp.KS_Obra__c;
            Boolean haveObra = obra != null;
            String orgaVent = opp.KS_Organizacion_de_ventas__c != null ? opp.KS_Organizacion_de_ventas__c : opp.KS_Organizacion__c;
            String marca = 
                (opp.KS_Canal__c != null ? opp.KS_Canal__c : '')
                + (orgaVent != null ? orgaVent : '')
                + (opp.KS_Agente_de_contabilizacion__c != null ? opp.KS_Agente_de_contabilizacion__c : '');
            Boolean haveMarca = marca != null && marca != '';
            if (!haveObra||!haveMarca) {continue;}
            System.debug(' -- -- -- -- -- -- -- -- obra+marca ' + opp.KS_Obra__c+marca);
            if (obraContaAgente.containsKey(opp.KS_Obra__c+marca)) 
            { 
                opp.addError('Error en oferta '+opp.Name+': Ya se está contabilizando para este segmento de Oferta y Agente.'); 
                continue;
            }
            else { System.debug(' -- -- -- -- -- -- -- -- obra+marca VALIDO'); }
            /*else {
            if (opp.KS_Agente_de_contabilizacion__c == 'Cliente final') { opp.KS_Prescrito__c = true; } // Cliente final = 'Prescriptor'
            }*/
            
            // SINCRONIZACIÓN
            Boolean contabiliza = opp.KS_Contabiliza__c;
            String contabilizador = opp.KS_Agente_de_contabilizacion__c;
            if (contabiliza && contabilizador != null && haveObra && opp.KS_Organizacion__c != null) {
                
                String sincroKey = opp.KS_Obra__c+opp.KS_Organizacion__c;
                if (contabilizador == 'Distribuidor' && !sincroDistrib.containsKey(sincroKey) ) 
                { 
                    opp.KS_Sincronizacion__c = opp.KS_Organizacion__c; sincroDistrib.put(sincroKey, opp); 
                    if (sincroInstala.containsKey(sincroKey)) 
                    { 
                        Opportunity oppS = sincroInstala.get(sincroKey); oppS.KS_Sincronizacion__c = null;
                        if (oppS.ID != null && !mapNewItems.containsKey(oppS.ID) ) {
                            oppS = oppUpdate.containsKey(oppS.ID)?oppUpdate.get(oppS.ID):oppS;
                            oppS.KS_Sincronizacion__c = null; oppUpdate.put(oppS.ID,oppS);
                        }
                    }
                    if (sincroClieFin.containsKey(sincroKey)) 
                    { 
                        Opportunity oppS = sincroClieFin.get(sincroKey); oppS.KS_Sincronizacion__c = null;
                        if (oppS.ID != null && !mapNewItems.containsKey(oppS.ID) ) {
                            oppS = oppUpdate.containsKey(oppS.ID)?oppUpdate.get(oppS.ID):oppS;
                            oppS.KS_Sincronizacion__c = null; oppUpdate.put(oppS.ID,oppS);
                        }
                    }
                }
                
                else if (contabilizador == 'Instalador' && sincroDistrib.containsKey(sincroKey)) 
                { 
                    opp.KS_Sincronizacion__c = null; 
                    Opportunity oppS = sincroDistrib.get(sincroKey); oppS.KS_Sincronizacion__c = oppS.KS_Organizacion__c;
                    if (oppS.ID != null && !mapNewItems.containsKey(oppS.ID) ) {
                        oppS = oppUpdate.containsKey(oppS.ID)?oppUpdate.get(oppS.ID):oppS;
                        oppS.KS_Sincronizacion__c = oppS.KS_Organizacion__c; oppUpdate.put(oppS.ID,oppS);
                    }
                }
                else if (contabilizador == 'Instalador' && !sincroInstala.containsKey(sincroKey) && !sincroDistrib.containsKey(sincroKey)) 
                { 
                    opp.KS_Sincronizacion__c = opp.KS_Organizacion__c; sincroInstala.put(sincroKey, opp); 
                    if (sincroClieFin.containsKey(sincroKey)) 
                    { 
                        Opportunity oppS = sincroClieFin.get(sincroKey);
                        if (oppS.ID != null && !mapNewItems.containsKey(oppS.ID) ) {
                            oppS = oppUpdate.containsKey(oppS.ID)?oppUpdate.get(oppS.ID):oppS;
                            oppS.KS_Sincronizacion__c = null; oppUpdate.put(oppS.ID,oppS);
                        }
                    }
                }
                
                else if (contabilizador == 'Cliente final' && (sincroDistrib.containsKey(sincroKey) || sincroInstala.containsKey(sincroKey)) )
                { 
                    opp.KS_Sincronizacion__c = null; 
                    if (sincroDistrib.containsKey(sincroKey)) 
                    { 
                        Opportunity oppS = sincroDistrib.get(sincroKey); oppS.KS_Sincronizacion__c = oppS.KS_Organizacion__c;
                        if (oppS.ID != null && !mapNewItems.containsKey(oppS.ID) ) {
                            oppS = oppUpdate.containsKey(oppS.ID)?oppUpdate.get(oppS.ID):oppS;
                            oppS.KS_Sincronizacion__c = oppS.KS_Organizacion__c; oppUpdate.put(oppS.ID,oppS);
                        }
                    }
                    else if (sincroInstala.containsKey(sincroKey)) 
                    { 
                        Opportunity oppS = sincroInstala.get(sincroKey); oppS.KS_Sincronizacion__c = oppS.KS_Organizacion__c;
                        if (oppS.ID != null && !mapNewItems.containsKey(oppS.ID) ) {
                            oppS = oppUpdate.containsKey(oppS.ID)?oppUpdate.get(oppS.ID):oppS;
                            oppS.KS_Sincronizacion__c = oppS.KS_Organizacion__c; oppUpdate.put(oppS.ID,oppS);
                        }
                    }
                }
                else if (contabilizador == 'Cliente final' && !sincroClieFin.containsKey(sincroKey) && !sincroInstala.containsKey(sincroKey) && !sincroDistrib.containsKey(sincroKey)) 
                { opp.KS_Sincronizacion__c = opp.KS_Organizacion__c; sincroClieFin.put(sincroKey, opp); }
            
                
            } else if (!contabiliza && haveObra && opp.KS_Organizacion__c != null) {

                Opportunity oppS = new Opportunity();
                String sincroKey = opp.KS_Obra__c+opp.KS_Organizacion__c;
                if (sincroDistrib.containsKey(sincroKey) && sincroDistrib.get(sincroKey).KS_Contabiliza__c && sincroDistrib.get(sincroKey).KS_Agente_de_contabilizacion__c != null) 
                { oppS = sincroDistrib.get(sincroKey); oppS.KS_Sincronizacion__c = oppS.KS_Organizacion__c; }
                else if (sincroInstala.containsKey(sincroKey) && sincroInstala.get(sincroKey).KS_Contabiliza__c && sincroInstala.get(sincroKey).KS_Agente_de_contabilizacion__c != null)
                { oppS = sincroInstala.get(sincroKey); oppS.KS_Sincronizacion__c = oppS.KS_Organizacion__c; }
                else if (sincroClieFin.containsKey(sincroKey) && sincroClieFin.get(sincroKey).KS_Contabiliza__c && sincroClieFin.get(sincroKey).KS_Agente_de_contabilizacion__c != null)
                { oppS = sincroClieFin.get(sincroKey); oppS.KS_Sincronizacion__c = oppS.KS_Organizacion__c; }
                
                Boolean contabilizaS = oppS.KS_Contabiliza__c && oppS.KS_Agente_de_contabilizacion__c != null;
                if (oppS.ID != null && !mapNewItems.containsKey(oppS.ID) && contabilizaS) {
                    oppS = oppUpdate.containsKey(oppS.ID)?oppUpdate.get(oppS.ID):oppS;
                    oppS.KS_Sincronizacion__c = oppS.KS_Organizacion__c; oppUpdate.put(oppS.ID,oppS);
                }
            }
        }
        return oppUpdate;
    }
        
    public static void updateOrganizacionVentas(Map<ID, KS_Obra__c> obraUpdate, Map<ID, Opportunity> ofertasObra) {
        
        List<ID> obraID = new List<ID>(); obraID.addAll(obraUpdate.keySet());
        List<ID> oferID = new List<ID>(); oferID.addAll(ofertasObra.keySet());
        List<Opportunity> obraOpps = [SELECT ID, KS_Obra__c, KS_Organizacion_de_ventas__c, KS_Protected__c, KS_Aprobado__c
                                      FROM Opportunity WHERE KS_Obra__c IN :obraID AND ID NOT IN :oferID ORDER BY KS_Obra__c];
        System.debug('-- JCAR ---------------------------------- Opp.executeBeforeUpsert - ' + obraOpps.size() + ' obraOpps - ' + obraOpps);
        obraOpps.addAll(ofertasObra.values());
        
        for (Opportunity opp : obraOpps) {
            
            String marca = opp.KS_Organizacion_de_ventas__c;
            if ( opp.KS_Obra__c == null ) { continue; }
            KS_Obra__c obra = new KS_Obra__c(); obra.ID = opp.KS_Obra__c;
            if (obraUpdate.containsKey(opp.KS_Obra__c)) 
            { obra = obraUpdate.get(opp.KS_Obra__c); }
            
            if (marca == 'SI10') {
                
                obra.KS_hasSimon__c = true;
                if (opp.KS_Protected__c) { obra.KS_hasSimon_Protected__c = true; }
                if (opp.KS_Aprobado__c) { obra.KS_hasSimon_Approv__c = true; }
                
            } else if (marca == 'FL31') {
                
                obra.KS_hasFluvia__c = true;
                if (opp.KS_Protected__c) { obra.KS_hasFluvia_Protected__c = true; }
                if (opp.KS_Aprobado__c) { obra.KS_hasFluvia_Approv__c = true; }   
                
            } else if (marca == 'IE20') {
                
                obra.KS_hasLighting__c = true;
                if (opp.KS_Protected__c) { obra.KS_hasLighting_Protected__c = true; }
                if (opp.KS_Aprobado__c) { obra.KS_hasLighting_Approv__c = true; }                    
            }
        }
        update obraUpdate.values();
    }
    
    public void executeAfterUpsert() {

        mapNewItems = mapNewItems != null ? mapNewItems : new Map<ID,SObject>();
        if (runningOpps == null) { runningOpps = new Map<ID,sObject>(); }
        if(!runningOpps.isEmpty()) {return;}
        if (mapNewItems != null && runningOpps != null) { runningOpps.putAll(mapNewItems); }
        
        List<Opportunity> oppLst = (List<Opportunity>)lstNewItems;
        List<Opportunity> updateOrgVentas = new List<Opportunity>();
        
        List<Opportunity> ofertasPadre = new List<Opportunity>();
        
        List<ID> idObra = new List<ID>(); List<ID> idOferta = new List<ID>();
        for (Opportunity opp : oppLst) {
            if (opp.KS_Obra__c != null) {
                idObra.add(opp.KS_Obra__c); idOferta.add(opp.ID);
            }
        }
        
        if (!idObra.isEmpty()) 
        {KS_Opportunity_Trigger_Utility.calculaIntervinientes(idObra);}
        
        if (!updateOrgVentas.isEmpty()) {update updateOrgVentas;}
        
        if (isInsert) { update ofertasPadre; }
        
        if (isUpdate) { setEstadoObra(); }
    }
    
    public void setPriceBook() {
        
        ID pbsID = null;
        List<Pricebook2> priceBookStandard = [SELECT Id FROM Pricebook2 WHERE isStandard = true and isActive = true LIMIT 1];
        if (priceBookStandard.size()>0) {pbsID = priceBookStandard[0].ID;}
        else {return;}
        setPriceBookID(pbsID);
    }
    public void setPriceBookID(ID priceBookID) {
        List<Opportunity> oppLst = (List<Opportunity>)lstNewItems;
        for (Opportunity opp : oppLst){
            
            if (opp.Pricebook2Id == null) {
                opp.Pricebook2Id = priceBookID;
            }
        }
    }
    
    public Boolean callValidClienteOferta(Opportunity oferta) { return validClienteOferta(oferta); }
    private Boolean validClienteOferta(Opportunity oferta) {
        //return true;
        // Si no se ha informado uno de los dos, saltará la validación por obligatoriedad
        if (oferta.KS_Distribuidor__c == null || oferta.KS_Organizacion_Cliente__c == null) { return true; }
        
        ID userID = /*oferta.OwnerId != null ? oferta.OwnerId : */userInfo.getUserId();
        System.debug('-- JCAR ---------------------------------- - validClienteOferta? userID - ' + userID);
        List<KS_Usuario_MarcaArea__c> marcareas = [SELECT ID, KS_Usuario__c, KS_Marca__c, KS_Area__c
                                                   FROM KS_Usuario_MarcaArea__c
                                                   WHERE KS_Usuario__c = :userID AND KS_Marca__c != null AND KS_Area__c != NULL];
        System.debug('-- JCAR ---------------------------------- - marcareas? ' + marcareas.size() + ' marcareas - ' + marcareas);
        List<String> validMarcareas = new List<String>();
        for (KS_Usuario_MarcaArea__c uma : marcareas) {
            if (uma.KS_Marca__c != null && uma.KS_Area__c != null) {
                validMarcareas.add(uma.KS_Marca__c + '' + uma.KS_Area__c);
            }
        }
        System.debug('-- JCAR ---------------------------------- - validClienteOferta? ' + validMarcareas.size() + ' validMarcareas - ' + validMarcareas);
        
        KS_Organizacion_Cliente__c orgCLie = [SELECT ID,KS_Area__c,KS_Organizacion_de_Ventas__c
                                              FROM KS_Organizacion_Cliente__c
                                              WHERE ID = :oferta.KS_Organizacion_Cliente__c];
        if (orgCLie.KS_Area__c != null && orgCLie.KS_Organizacion_de_Ventas__c != null) {
            
            String marcarea = orgCLie.KS_Organizacion_de_Ventas__c + '' + orgCLie.KS_Area__c;
            System.debug('-- JCAR ---------------------------------- - validClienteOferta? orgCLie.marcarea - ' + marcarea);
            for (String mca : validMarcareas) {
                if (marcarea.containsIgnoreCase(mca)) { return true; }
            }
        }
        
        oferta.addError('El Cliente y/o Oferta Cliente seleccionados no son válidos para el Usuario.');
        return false;
    }
    
    public void setTerritory() {

        List<Opportunity> saveOpp = setTerritoryOferta( (List<Opportunity>)lstNewItems );
    }
    
    public List<Opportunity> setTerritoryOferta(List<Opportunity> ofertas) {

        List<Opportunity> ofertasUpdate = new List<Opportunity>();
        List<ID> cuentas = new List<ID>();
        List<String> orgventas = new List<String>();
        
        if ( ofertas.isEmpty() ) {return null;}
        
        for (Opportunity oferta : ofertas) {
            //if (oferta.Territory2Id != null) {continue;}  
            cuentas.add(oferta.KS_Distribuidor__c);
            orgventas.add(oferta.KS_Organizacion_de_ventas__c);
        }
        
        if ( cuentas.isEmpty() ) {return null;}
        if ( orgventas.isEmpty() ) {return null;}
        
        List<ObjectTerritory2Association> otaLst = 
            [SELECT Id, ObjectId, Territory2Id, Territory2.KS_Organizacion_Ventas__c, SobjectType
             FROM ObjectTerritory2Association WHERE ObjectId IN :cuentas
             AND Territory2.KS_Organizacion_Ventas__c IN :orgventas];
        System.debug('-- JCAR ---------------------------------- - setTerritoryOferta ' + otaLst.size() + ' otaLst - ' + otaLst);
        
        if ( otaLst.isEmpty() ) {return null;}
        
        for (Opportunity oferta : ofertas) {
            for (ObjectTerritory2Association ota : otaLst) {
                
                if (oferta.KS_Distribuidor__c == ota.ObjectId && oferta.KS_Organizacion_de_ventas__c == ota.Territory2.KS_Organizacion_Ventas__c) {
                    
                    oferta.Territory2Id = ota.Territory2Id; ofertasUpdate.add(oferta);
                }
            }
        }

        return ofertasUpdate;
    }
    
    public void setUbicacionObra() {
        
        List<Opportunity> oppLst = (List<Opportunity>)lstNewItems;
        List<Opportunity> oppLstOLD = isInsert ? new List<Opportunity>() : (List<Opportunity>)lstOldItems;
        
        Map<ID, Set<String>> obraMarcas = new Map<ID, Set<String>>();
        Map<ID, String> obraCodPos = new Map<ID, String>();
        
        Set<ID> idObraSet = new Set<ID>(); List<ID> idObraLst = new List<ID>();
        Set<String> idMarcaSet = new Set<String>(); List<String> idMarcaLst = new List<String>();
        
        for (Integer i = 0; i < oppLst.size(); i++) {
            
            Opportunity opp = oppLst.get(i);
            Opportunity oppOLD = isInsert ? new Opportunity() : oppLstOLD.get(i);
            
            if (opp.KS_Obra__c == null) {continue;}
            if (opp.KS_Organizacion_de_ventas__c != oppOLD.KS_Organizacion_de_ventas__c || isInsert) {

                idObraSet.add(opp.KS_Obra__c);
                idMarcaSet.add(opp.KS_Organizacion_de_ventas__c);
                
                Set<String> marcas = new Set<String>();
                if (obraMarcas.containsKey(opp.KS_Obra__c)) { marcas = obraMarcas.get(opp.KS_Obra__c); }
                marcas.add(opp.KS_Organizacion_de_ventas__c);
                obraMarcas.put(opp.KS_Obra__c, marcas);
            }
        }
        
        idObraLst.addAll(idObraSet);
        List<KS_Obra__c> obras = [SELECT ID, KS_Codigo_Postal__c FROM KS_Obra__c
                                  WHERE ID IN :idObraLst];
        for (KS_Obra__c obra : obras) {
            if (obra.KS_Codigo_Postal__c != null) {
                obraCodPos.put(obra.ID, obra.KS_Codigo_Postal__c);
            }
        }
        
        System.debug('-- JCAR ---------------------------------- - setUbicacionObra ' + obraMarcas.size() + ' obraMarcas - ' + obraMarcas);
        System.debug('-- JCAR ---------------------------------- - setUbicacionObra ' + obraMarcas.size() + ' obraCodPos - ' + obraCodPos);        
        
        idMarcaLst.addAll(idMarcaSet);
        List<KS_Estructura_Geografica__c> esGeogLst = 
            [SELECT Id, KS_CPDesde__c, KS_CPHasta__c, KS_Delegacion__c, KS_Area__c, KS_Zona__c, KS_Organizacion_de_ventas__c, KS_CountryCode__c 
             FROM KS_Estructura_Geografica__c WHERE KS_Organizacion_de_ventas__c IN :idMarcaLst];
        
        Map<ID, Set<ID>> ubicacionObraMap = new Map<ID, Set<ID>>();
        
        // Supondremos que las obras siempre son en España
        for (ID obraID : obraCodPos.keySet()) {
            String codPostal = obraCodPos.get(obraID);
            Set<String> marcas = obraMarcas.get(obraID);
            
            for (KS_Estructura_Geografica__c eg : esGeogLst) {
                
                Boolean bingo = false;
                if (marcas.contains(eg.KS_Organizacion_de_ventas__c)) {
                    
                    String dsd = eg.KS_CPDesde__c;
                    String hst = eg.KS_CPHasta__c;
                    
                    if (codPostal.length() == 4) { 
                        codPostal = '0'+codPostal;
                    }
                    bingo = codPostal.startsWithIgnoreCase(dsd.substring(0,2));                    
                }
                if (bingo) {
                    
                    Set<ID> egIDs = new Set<ID>();
                    if (ubicacionObraMap.containsKey(obraID)) { egIDs = ubicacionObraMap.get(obraID); }
                    egIDs.add(eg.ID); ubicacionObraMap.put(obraID, egIDs);
                    break;
                }
            }
        }
        
        System.debug('-- JCAR ---------------------------------- - setUbicacionObra ' + ubicacionObraMap.size() + ' ubicacionObraMap - ' + ubicacionObraMap);
        
        List<KS_Obra_Ubicacion__c> ubacionesObra = new List<KS_Obra_Ubicacion__c>();
        for (ID obraID : ubicacionObraMap.keySet()) {
            
            Set<ID> egID = ubicacionObraMap.get(obraID);
            for (ID eg : egID) {
                KS_Obra_Ubicacion__c ubo = new KS_Obra_Ubicacion__c();
                ubo.KS_Obra__c = obraID;
                ubo.KS_Ubicacion__c = eg;
                ubo.KS_ID__c = ubo.KS_Obra__c + '-' + ubo.KS_Ubicacion__c;
                ubacionesObra.add(ubo);
            }
        }
        
        System.debug('-- JCAR ---------------------------------- - setUbicacionObra ' + ubacionesObra.size() + ' ubacionesObra - ' + ubacionesObra);
        
        Schema.DescribeFieldResult field = KS_Obra_Ubicacion__c.KS_ID__c.getDescribe();
        Schema.sObjectField idUbOb = field.getSObjectField();
        Database.UpsertResult[] upsertResult = Database.upsert(ubacionesObra, idUbOb, true);         
    }
    
    public Boolean getClosed(Opportunity oferta) {
        return oferta != null && 
            (oferta.StageName.containsIgnoreCase('Adjudicada') ||
             oferta.StageName.containsIgnoreCase('Perdida')
            )
            && !oferta.StageName.containsIgnoreCase('otro Distribuidor');
    }
    public Boolean getDescarted(Opportunity oferta) {
        return oferta != null && oferta.StageName != null && oferta.StageName.containsIgnoreCase('otro Distribuidor');
    }    
    
    public void setEstadoObra() {
       
        List<Opportunity> oppLst = (List<Opportunity>)lstNewItems;
        List<Opportunity> oppLstOLD = isInsert ? new List<Opportunity>() : (List<Opportunity>)lstOldItems;
            
        // CAMBIO ESTADOS
        Map<ID, KS_Obra__c> obraChangeEstado = new Map<ID, KS_Obra__c>();
        
        for (Integer i = 0; i < oppLst.size(); i++) {

            Opportunity opp = oppLst.get(i);
            Opportunity oppOLD = isInsert ? new Opportunity() : oppLstOLD.get(i);        
            
            Id obra = opp.KS_Obra__c;
            Boolean haveObra = obra != null;            
            Boolean cambioEstado = opp.StageName != oppOLD.StageName;
            String estado = opp.StageName;
            String obraEstado = opp.KS_Obra_Estado__c;
            
            Boolean contabiliza = opp.KS_Contabiliza__c;
            String contabilizador = opp.KS_Agente_de_contabilizacion__c;            
            
            // Cambios de ESTADO
            if (haveObra && (cambioEstado || contabiliza)) {
                
                KS_Obra__c obraOferta = new KS_Obra__c();
                obraOferta.ID = obra;
                if (obraChangeEstado.containsKey(obra))
                { obraOferta = obraChangeEstado.get(obra); }
                
                Boolean save = false;
                Boolean contabilizaDistrORInst = (contabilizador == 'Distribuidor' || contabilizador == 'Instalador');
                if (contabiliza && contabilizaDistrORInst && obraEstado == 'Proyecto') {
                    obraOferta.KS_Fase__c = 'Obra'; save = true;
                } else if (estado == 'Parada' && obraEstado != 'Parada') {
                    obraOferta.KS_Fase__c = 'Parada'; save = true;
                } else if (cambioEstado && contabiliza && obraEstado == 'Parada') {
                    if (estado == 'Pendiente' || estado == 'Licitación') {
                        if (contabilizaDistrORInst) {
                            obraOferta.KS_Fase__c = 'Obra';
                        } else {
                            obraOferta.KS_Fase__c = 'Proyecto';
                        }
                        save = true;
                    }
                }

                if (save) { obraChangeEstado.put(obra, obraOferta); }
            }
        }
        
        if (obraChangeEstado.size()>0) { update obraChangeEstado.values(); }        
    }
    
    public void executeDuplicate() {
        
        // OBRA PROTEGIDA / DUPLICIDAD OFERTAS
        Map<ID, Opportunity> oppToClone = new Map<ID, Opportunity>();
        List<Opportunity> oppLst = (List<Opportunity>)lstNewItems;
        List<Opportunity> oppLstOLD = isInsert ? new List<Opportunity>() : (List<Opportunity>)lstOldItems;          
        
        // COMPROBACIÓN PREVIA: Que la obra no esté protegida para esa marca.
        List<ID> idObras = new List<ID>(); List<ID> idOpps = new List<ID>(); List<String> idOrgVnts = new List<String>();
        for (Opportunity opp : oppLst) {
            
            if (opp.KS_Obra__c != null && opp.KS_Protected__c) {
                
                idObras.add(opp.KS_Obra__c); idOpps.add(opp.ID); idOrgVnts.add(opp.KS_Organizacion_de_ventas__c);
            }
        }
        
        System.debug('-- JCAR ---------------------------------- - executeDuplicate ' + idObras.size() + ' idObras - ' + idObras);
        System.debug('-- JCAR ---------------------------------- - executeDuplicate ' + idOpps.size() + ' idOpps - ' + idOpps);
        System.debug('-- JCAR ---------------------------------- - executeDuplicate ' + idOrgVnts.size() + ' idOrgVnts - ' + idOrgVnts);
        
        if (idObras.size()>0 && idOpps.size()>0 && idOrgVnts.size()>0) {
            
            List<Opportunity> oportunidades = [SELECT ID FROM Opportunity
                                               WHERE KS_Protected__c = TRUE
                                               AND ID not IN :idOpps AND KS_Obra__C IN :idObras
                                               AND KS_Organizacion_de_ventas__c IN :idOrgVnts];
            System.debug('-- JCAR ---------------------------------- - executeDuplicate ' + oportunidades.size() + ' oportunidades protegidas? - ' + oportunidades);
            
            if (oportunidades.size()>0) {
                for (Opportunity opp : oppLst) {
                    opp.addError('La obra ya está protegida por otra oferta.');
                }
                return;
            }
        }
        
        // Primer paso, generamos el clon de la oferta eliminando/reseteando lo que no nos interesa
        for (Integer i = 0; i < oppLst.size(); i++) {
            
            Opportunity opp = oppLst.get(i);
            Opportunity oppOLD = isInsert ? new Opportunity() : oppLstOLD.get(i);             
            
            if (opp.KS_Obra__c != null && opp.KS_Aprobado__c && opp.KS_Protected__c && !oppOLD.KS_Aprobado__c) {
                
                Opportunity cloneOpp = cloneOpportunity(opp);
                oppToClone.put(opp.ID, cloneOpp);
            }            
        }
        
        System.debug('-- JCAR ---------------------------------- - executeDuplicate ' + oppToClone.size() + ' oppToClone - ' + oppToClone);
        
        if (oppToClone.size()>0) {
            
            // Insertamos los clones para tener sus referencias
            insert oppToClone.values();
            
            List<ID> oppID = new List<ID>(); oppID.addAll(oppToClone.keySet());
            // Segundo paso, recuperamos las ID de las ofertas clonadas
            // Para con ellas sacar sus Productos (Líneas de Oportunidad)
            // Y las clonamos reasignando con la nueva ID
            
            List<OpportunityLineItem> oppLToClone = new List<OpportunityLineItem>();
            List<OpportunityLineItem> oppLlst = [SELECT ID, OpportunityId, UnitPrice, Quantity, PricebookEntryId, KS_Variedad_OK__c, KS_Volumen_OK__c, 
                                                 KS_Comentarios__c, KS_Competencia__c, KS_Descuento_neto__c, KS_precio_neto__c, 
                                                 KS_Cantidad__c, KS_Cantidad_Ficha__c, KS_Ficha__C, KS_Dto_base_1__c, KS_Dto_base_2__c, 
                                                 KS_Dto_adicional_1__c, KS_Dto_Variedad__c, KS_dto_volumen__c, KS_ZPN0__c, KS_Prescrito__c
                                                 FROM OpportunityLineItem 
                                                 WHERE OpportunityId in :oppID];
            
            System.debug('-- JCAR ---------------------------------- - executeDuplicate ' + oppLlst.size() + ' oppLlst - ' + oppLlst);
            
            FOR (OpportunityLineItem oppL : oppLlst) {
                
                if (oppToClone.containsKey(oppL.OpportunityId)) {
                    OpportunityLineItem oppLClone = cloneOpportunityLineItem(oppL,oppToClone.get(oppL.OpportunityId).ID);
                    oppLToClone.add(oppLClone);
                }
            }
            
            System.debug('-- JCAR ---------------------------------- - executeDuplicate ' + oppLToClone.size() + ' oppLToClone - ' + oppLToClone);
            
            if (oppLToClone.size()>0) { insert oppLToClone; }
        }        
    }
    
    public static Opportunity cloneOpportunity(Opportunity opp) {
        Opportunity cloneOpp = opp.clone(false, true); // preserveID false, deepClone true
        cloneOpp.KS_Aprobado__c = false;
        cloneOpp.KS_Protected__c = false;
        cloneOpp.KS_Submitted_for_Approval__c = false;
        
        cloneOpp.KS_Nivel2__c = false;
        cloneOpp.KS_Nivel3__c = false;
        cloneOpp.KS_Nivel4__c = false;
        
        cloneOpp.KS_Resp_Jefe_de_Area__c = null;
        cloneOpp.KS_Resp_Conectividad__c = null;
        cloneOpp.KS_Resp_Iluminacion__c = null;
        cloneOpp.KS_Resp_Sist_Control__c = null;
        cloneOpp.KS_Resp_Vehiculo_Electrico__c = null;
        cloneOpp.KS_Resp_resto_de_gamas__c = null;
        cloneOpp.KS_Resp_negocio_iberia__c = null;
        cloneOpp.KS_Resp_Negocio_Iberia_2__c = null;
        
        cloneOpp.Name = cloneOpp.Name + ' v1';
        return cloneOpp;
    }
    public static OpportunityLineItem cloneOpportunityLineItem(OpportunityLineItem oppL, ID oppID) {
        OpportunityLineItem oppLClone =  oppL.clone(false, true);
        oppLClone.KS_Destinatario__c = null;
        oppLClone.KS_Material_sin_cargo__c = false;
        oppLClone.KS_Dto_adicional_2__c = null;
        oppLClone.KS_Dto_Instalador__c = null;
        oppLClone.KS_Dto_cliente_final__c = null;
        oppLClone.OpportunityId = oppID;//oppToClone.get(oppL.OpportunityId).ID;
        return oppLClone;
    }
}