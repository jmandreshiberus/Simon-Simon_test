public without sharing class KS_Condicion_Obra_Trigger extends KS_TriggerController {

    public KS_Condicion_Obra_Trigger (Boolean isAfter, Boolean isBefore, Boolean isDelete, Boolean isInsert, Boolean isUndelete, Boolean isUpdate,
        List<sObject> lstNewItems, Map<Id, sObject> mapNewItems, List<sObject> lstOldItems, Map<Id, sObject> mapOldItems)
    {
        super(isAfter, isBefore, isDelete, isInsert, isUndelete, isUpdate, lstNewItems, mapNewItems, lstOldItems, mapOldItems);
    }
    
    public static Boolean blocked() { System.debug('-- TRIGGER BLOCKED! --'); return Test.isRunningTest() && KS_Trigger_Test.blockTrigger; }
    
    protected override void runBeforeInsert(){ if(blocked()){return;} executeBeforeInsert(); }
    protected override void runBeforeUpdate(){ if(blocked()){return;} executeBeforeUpdate(); } 
    public void executeBeforeInsert() { executeBeforeUpsert(); }
    public void executeBeforeUpdate() { executeBeforeUpsert(); }       
    public void executeBeforeUpsert() {
        
        List<KS_Condicion_de_Obra__c> condicionesLst = (List<KS_Condicion_de_Obra__c>)lstNewItems;
        List<KS_Condicion_de_Obra__c> condiciones = new List<KS_Condicion_de_Obra__c>();
        Map<ID, Opportunity> ofertas = new Map<ID, Opportunity>();
        
        List<ID> ofertasID = new List<ID>();
        List<String> clavesSerieFamilia = new List<String>();
        
        Set<String> serieSet = new Set<String>(); List<String> series = new List<String>();
        Set<String> subserieSet = new Set<String>(); List<String> subseries = new List<String>();
        Set<String> familiaSet = new Set<String>(); List<String> familias = new List<String>();        
        
        Map<String,Set<ID>> mapElementos = new Map<String,Set<ID>>();
        Map<String,Decimal> mapDescuentos = new Map<String,Decimal>();   
        
        for (KS_Condicion_de_Obra__c co : condicionesLst) {
            if (!co.KS_Aprobado__c) {
                
                if (co.KS_Dto_adicional_2__c != null && co.KS_Dto_adicional_2__c > 0) {
                    
                    String clave = ''; // Serie+Subserie+Familia
                    clave += co.KS_Serie__c != null ? co.KS_Serie__c : '';
                    clave += co.KS_Subserie__c != null ? co.KS_Subserie__c : '';
                    clave += co.KS_Familia__c != null ? co.KS_Familia__c : '';
                    
                    if (co.KS_Serie__c != null) { serieSet.add(co.KS_Serie__c); }
                    if (co.KS_Subserie__c != null) { subserieSet.add(co.KS_Subserie__c); }
                    if (co.KS_Familia__c != null) { familiaSet.add(co.KS_Familia__c); }
                    
                    Decimal dtoad2 = mapDescuentos.containsKey(clave) ? mapDescuentos.get(clave) : 0;
                    dtoad2 = co.KS_Dto_adicional_2__c > dtoad2 ? co.KS_Dto_adicional_2__c : dtoad2;
                    mapDescuentos.put(clave, dtoad2);
                    
                    Set<ID> conSet = new Set<ID>();
                    if (mapElementos.containsKey(clave))
                    { conSet = mapElementos.get(clave); }
                    conSet.add(co.ID); mapElementos.put(clave, conSet);
                    
                    clavesSerieFamilia.add(clave);
                    ofertasID.add(co.KS_Oportunidad__c);
                    ofertas.put(co.KS_Oportunidad__c, null);
                    
                    co.KS_Nivel2__c = false; co.KS_Nivel3__c = false; co.KS_Nivel4__c = false;
                    co.KS_Resp_Conectividad__c = null; co.KS_Resp_Iluminacion__c = null;
                    co.KS_Resp_Jefe_de_Area__c = null; co.KS_Resp_Negocio_Iberia_2__c = null;
                    co.KS_Resp_negocio_iberia__c = null; co.KS_Resp_resto_de_gamas__c = null;
                    co.KS_Resp_Sist_Control__c = null; co.KS_Resp_Vehiculo_Electrico__c = null;
                    condiciones.add(co);
                }
                
            }
        }

        Map<ID,String> paisesMap = new Map<ID,String>();
        Map<ID,String> orgVentas = new Map<ID,String>();
        Map<ID,ID> orgClientes = new Map<ID,ID>();
        List<String> marcaLST = new List<String>();
		
        List<Opportunity> oppLst = [SELECT ID, KS_Organizacion_de_Ventas__c, KS_Canal__c, KS_Pais__c, 
                                    KS_Sector__c, KS_Area__c, KS_Organizacion_Cliente__c, Territory2Id
                                    FROM Opportunity WHERE ID IN :ofertasID];
        for (Opportunity opp : oppLst) {
            
            ofertas.put(opp.ID, opp);
            orgVentas.put(opp.ID, opp.KS_Organizacion_de_Ventas__c);
            paisesMap.put(opp.ID, opp.KS_Pais__c);
            orgClientes.put(opp.ID, opp.KS_Organizacion_Cliente__c);
            marcaLST.add(opp.KS_Organizacion_Cliente__c);
        }
               
        System.debug('-- JCAR ---------------------------------- Opp.executeBeforeUpsert - ' + ofertas.size() + ' ofertas - ' + ofertas);

        Map<ID,ID> responsables = new Map<ID,ID>();
        
        List<KS_Organizacion_Cliente__c> orgClLst = [SELECT ID,KS_Responsable__c FROM KS_Organizacion_Cliente__c
                                                     WHERE ID in :marcaLST];
        for (KS_Organizacion_Cliente__c oc : orgClLst) {
            for (ID oppID : orgClientes.keySet()) {
                ID ocID = orgClientes.get(oppID);
                if (oc.ID == ocID && oc.KS_Responsable__c != null)  {
                    responsables.put(oppID , oc.KS_Responsable__c);
                }
            }
        }
        
        if (responsables.size() < ofertas.size()) {

            Map<ID,Opportunity> oppSinTerr = new Map<ID,Opportunity>();
            
            List<String> orgVnLST = new List<String>();
            List<String> canalLST = new List<String>();
            List<String> sectrLST = new List<String>();
            List<String> areaGLst = new List<String>();
            MAP<ID,ID> terrMAP = new MAP<ID,ID>();
            
            for (ID oppID : ofertas.keyset()) {
                
                if (!responsables.containsKey(oppID)) {
                    
                    Opportunity opp = ofertas.get(oppID);
                    oppSinTerr.put(opp.ID, opp);
                    
                    terrMAP.put(opp.Territory2Id, opp.ID);
                    
                    orgVnLST.add(opp.KS_Organizacion_de_Ventas__c);
                    canalLST.add(opp.KS_Canal__c);
                    sectrLST.add(opp.KS_Sector__c);
                    areaGLst.add(opp.KS_Area__c);                     
                }
               
            }
            
            List<ID> terrID = new List<ID>(); terrID.addAll(terrMAP.keySet());
            
            Map<String,ID> terrType = new Map<String,ID>();
            List<Territory2Type> terrLst = [SELECT ID, DeveloperName FROM Territory2Type];
            for (Territory2Type tp : terrLst) {
                terrType.put(tp.DeveloperName, tp.ID);
            }  
            
            System.debug('-- JCAR ---------------------------------- Opp.executeBeforeUpsert - ' + terrType.size() + ' terrType - ' + terrType);             
            System.debug('-- JCAR ---------------------------------- Opp.executeBeforeUpsert - ' + orgVnLST.size() + ' orgVnLST - ' + orgVnLST);
            System.debug('-- JCAR ---------------------------------- Opp.executeBeforeUpsert - ' + canalLST.size() + ' canalLST - ' + canalLST);
            System.debug('-- JCAR ---------------------------------- Opp.executeBeforeUpsert - ' + sectrLST.size() + ' sectrLST - ' + sectrLST);
            System.debug('-- JCAR ---------------------------------- Opp.executeBeforeUpsert - ' + areaGLst.size() + ' areaGLst - ' + areaGLst);
            System.debug('-- JCAR ---------------------------------- Opp.executeBeforeUpsert - ' + terrMAP.size() + ' terrMAP - ' + terrMAP);
            
            List<UserTerritory2Association> terrOferta = 
                [SELECT Id, UserId, Territory2Id, RoleInTerritory2,
                 Territory2.KS_Organizacion_Ventas__c,
                 Territory2.KS_Canal__c,
                 Territory2.KS_Sector_Distribuidor__c,
                 Territory2.KS_Area__c
                 FROM UserTerritory2Association 
                 WHERE RoleInTerritory2 = 'JAR'
                 AND Territory2.KS_Organizacion_Ventas__c IN :orgVnLST
                 AND Territory2.KS_Canal__c IN :canalLST
                 AND Territory2.KS_Sector_Distribuidor__c IN :sectrLST
                 AND Territory2.KS_Area__c IN :areaGLst
                 AND Territory2.Territory2TypeId = :terrType.get('KS_Area')
                ];
            System.debug('-- JCAR ---------------------------------- Opp.executeBeforeUpsert - ' + terrOferta.size() + ' terrOferta - ' + terrOferta);
            for (Opportunity opp : oppSinTerr.values()) {
                for (UserTerritory2Association uta : terrOferta) {
                    if (uta.Territory2.KS_Organizacion_Ventas__c == opp.KS_Organizacion_de_Ventas__c
                        && uta.Territory2.KS_Canal__c == opp.KS_Canal__c
                        && uta.Territory2.KS_Sector_Distribuidor__c == opp.KS_Sector__c
                        && uta.Territory2.KS_Area__c == opp.KS_Area__c) {
                            
                            responsables.put(opp.ID , uta.UserId);
                        }
                }
            }            
        }
        
        series.addAll(serieSet);
        subseries.addAll(subSerieSet);
        familias.addAll(familiaSet);        
        
        System.debug('-- JCAR ---------------------------------- Opp.executeBeforeUpsert - ' + mapDescuentos.size() + ' mapDescuentos - ' + mapDescuentos);
        System.debug('-- JCAR ---------------------------------- Opp.executeBeforeUpsert - ' + mapElementos.size() + ' mapElementos - ' + mapElementos);
        System.debug('-- JCAR ---------------------------------- Opp.executeBeforeUpsert - ' + responsables.size() + ' responsables - ' + responsables);
        System.debug('-- JCAR ---------------------------------- Opp.executeBeforeUpsert - ' + condiciones.size() + ' condiciones - ' + condiciones);
        System.debug('-- JCAR ---------------------------------- Opp.executeBeforeUpsert - ' + ofertas.values().size() + ' ofertas.values() - ' + ofertas.values());
        System.debug('-- JCAR ---------------------------------- Opp.executeBeforeUpsert - ' + orgVentas.size() + ' orgVentas - ' + orgVentas);
        System.debug('-- JCAR ---------------------------------- Opp.executeBeforeUpsert - ' + clavesSerieFamilia.size() + ' clavesSerieFamilia - ' + clavesSerieFamilia);
        System.debug('-- JCAR ---------------------------------- Opp.executeBeforeUpsert - ' + series.size() + ' series - ' + series);
        System.debug('-- JCAR ---------------------------------- Opp.executeBeforeUpsert - ' + subseries.size() + ' subseries - ' + subseries);
        System.debug('-- JCAR ---------------------------------- Opp.executeBeforeUpsert - ' + familias.size() + ' familias - ' + familias);
        
        if (mapDescuentos.size() > 0) {
            KS_Aprobaciones_Controller.setAprobacionesOferta(mapDescuentos, null, mapElementos, responsables, condiciones, ofertas.values(), orgVentas, clavesSerieFamilia,
                                                             subseries, series, familias, paisesMap);
        }
    }    
    
    protected override void  runAfterUpdate(){ executeAfterUpdate(); }
    public void executeAfterUpdate() {
        
        List<KS_Condicion_de_Obra__c> condiciones = (List<KS_Condicion_de_Obra__c>)lstNewItems;
        List<KS_Condicion_de_Obra__c> condicionesAprobadas = new List<KS_Condicion_de_Obra__c>();
        Map<ID, Set<String>> obrasAprobadas = new Map<ID, Set<String>>();        
        
        for (KS_Condicion_de_Obra__c co : condiciones) {
            if (co.KS_Aprobado__c && co.KS_Obra__c != null && co.KS_Oportunidad__c != null && co.KS_Organizacion_Ventas__c != null) {
                condicionesAprobadas.add(co);
                
                Set<String> orgVentasAprob = new Set<String>();
                if ( obrasAprobadas.containsKey(co.KS_Obra__c) ) { orgVentasAprob = obrasAprobadas.get(co.KS_Obra__c); }
                orgVentasAprob.add(co.KS_Organizacion_Ventas__c);
                obrasAprobadas.put(co.KS_Obra__c, orgVentasAprob);
            }
        }
        
        Map<ID, KS_Obra__c> obrasUpdate = new Map<ID, KS_Obra__c>();
        for (ID obraID : obrasAprobadas.keySet()) {
            
            KS_Obra__c obra = new KS_Obra__c(); obra.ID = obraID;
            if ( obrasUpdate.containsKey(obraID) ) { obra = obrasUpdate.get(obraID); }
            
            Set<String> orgVentas = obrasAprobadas.get(obraID);
            if (orgVentas.contains('SI10')) {

                obra.KS_hasSimon__c = true;
                obra.KS_hasSimon_condicion__c = true;

            } else if (orgVentas.contains('FL31')) {

                obra.KS_hasFluvia__c = true;
                obra.KS_hasFluvia_condicion__c = true;   

            } else if (orgVentas.contains('IE20')) {

                obra.KS_hasLighting__c = true;
                obra.KS_hasLighting_condicion__c = true;                   
            }
            
            obrasUpdate.put(obraID, obra);
        }
        update obrasUpdate.values();

		List<KS_Condicion_de_obra_publico__c> condicionesPublicas = new List<KS_Condicion_de_obra_publico__c>();
        for (KS_Condicion_de_Obra__c co : condicionesAprobadas) {
            if (co.KS_Aprobado__c && co.KS_Obra__c != null) { // Por si acaso
                
                KS_Condicion_de_obra_publico__c cop = new KS_Condicion_de_obra_publico__c();
                cop.KS_ID_Condicion__c = co.ID;
                cop.KS_Obra__c = co.KS_Obra__c;
                cop.KS_Estado_de_aprobacion__c = co.KS_Aprobado__c;
                cop.KS_Solicitante__c = co.CreatedById;
                cop.KS_Serie__c = co.KS_Serie__c;
                condicionesPublicas.add(cop);
            }
        }
        Schema.DescribeFieldResult field = KS_Condicion_de_obra_publico__c.KS_ID_Condicion__c.getDescribe();
        Schema.sObjectField idExt = field.getSObjectField();
        Database.UpsertResult[] upsertResult = Database.upsert(condicionesPublicas, idExt, false);          
    }   
}