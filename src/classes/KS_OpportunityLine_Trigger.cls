public without sharing class KS_OpportunityLine_Trigger extends KS_TriggerController {

    public KS_OpportunityLine_Trigger (Boolean isAfter, Boolean isBefore, Boolean isDelete, Boolean isInsert, Boolean isUndelete, Boolean isUpdate,
        List<sObject> lstNewItems, Map<Id, sObject> mapNewItems, List<sObject> lstOldItems, Map<Id, sObject> mapOldItems)
    {
        super(isAfter, isBefore, isDelete, isInsert, isUndelete, isUpdate, lstNewItems, mapNewItems, lstOldItems, mapOldItems);
    }
    
    public static Boolean blocked() { System.debug('-- TRIGGER BLOCKED! --'); return Test.isRunningTest() && KS_Trigger_Test.blockTrigger; }
    public static Map<Id, sObject> inUse = new Map<Id, sObject>();
    
    protected override void  runAfterInsert(){ if(blocked()){return;} executeAfterInsert(); }
    protected override void  runAfterUpdate(){ if(blocked()){return;} executeAfterUpdate(); }     
    
    public void executeAfterInsert() { executeAfterUpsert(); }
    public void executeAfterUpdate() { executeAfterUpsert(); }
    public void executeAfterUpsert() {

        Map<Id, OpportunityLineItem> oppLineMap = new Map<Id, OpportunityLineItem>();
        oppLineMap.putAll((Map<Id, OpportunityLineItem>)mapNewItems);
        if (inUse.isEmpty() || isInsert) { inUse = oppLineMap; }
        else if (isUpdate) {
            oppLineMap.keySet().removeAll(inUse.keySet());
            if (oppLineMap.isEmpty()) {return;}
            inUse.putAll(oppLineMap);
        }
            
        List<OpportunityLineItem> lineasOferta = (List<OpportunityLineItem>)oppLineMap.values();
        
        List<ID> prodIDlst = new List<ID>();
        List<ID> obrasList = new List<ID>();

        List<String> orgaVList = new List<String>();
        List<String> canalList = new List<String>();
        List<String> sectrList = new List<String>();
        
        System.debug('----------------------------------------JCAR - ' + lineasOferta.size() + ' lineasOferta : ' + lineasOferta);
        for (OpportunityLineItem oL : lineasOferta ) {
            
            if (oL.KS_Obra__c != null) { 
                
                if (oL.Product2Id != null) { prodIDlst.add(oL.Product2Id); }
                obrasList.add(oL.KS_Obra__c);

                orgaVList.add(oL.KS_Organizacion_Ventas__c);
                canalList.add(oL.KS_Canal__c);
                sectrList.add(oL.KS_Sector__c);
            }
        }
        Map<ID, KS_Organizacion_Producto__c> orgProductos = new Map<ID, KS_Organizacion_Producto__c>();
        List<KS_Organizacion_Producto__c> orgPList = [SELECT ID, KS_Serie_Gama__c, KS_Subserie__c, KS_Producto__c, 
                                                      KS_Organizacion_de_Ventas__c, KS_Canal_de_distribucion__c, KS_Sector__c
                                                      FROM KS_Organizacion_Producto__c
                                                      WHERE KS_Producto__c IN :prodIDlst AND KS_Organizacion_de_Ventas__c IN :orgaVList
                                                      AND KS_Canal_de_distribucion__c IN :canalList AND KS_Sector__c IN :sectrList];
        FOR (OpportunityLineItem oL : lineasOferta) {
            FOR (KS_Organizacion_Producto__c oP : orgPList) {
                
                if (oP.KS_Producto__c == oL.KS_Producto__c && oP.KS_Organizacion_de_Ventas__c == oL.KS_Organizacion_Ventas__c &&
                    oP.KS_Canal_de_distribucion__c == oL.KS_Canal__c && oP.KS_Sector__c == oL.KS_Sector__c) {
                    
                        orgProductos.put(oP.KS_Producto__c, oP);
                }
            }
        }
        
        Map<String, KS_Solucion_propuesta__c> lineasPropuestasMap = new Map<String, KS_Solucion_propuesta__c>();
        List<KS_Solucion_propuesta__c> propuestasLST = [SELECT ID,Name,KS_Cantidad__c,KS_Obra__c,KS_Ficha__c,KS_Producto__c
                                                         FROM KS_Solucion_propuesta__c 
                                                         WHERE KS_Producto__c IN :prodIDlst AND KS_Obra__c IN :obrasList];
        for (KS_Solucion_propuesta__c sp : propuestasLST) {
            lineasPropuestasMap.put(sp.KS_Obra__c + '' + sp.KS_Producto__c, sp);
        }
        System.debug('----------------------------------------JCAR - ' + lineasPropuestasMap.size() + ' lineasPropuestasMap : ' + lineasPropuestasMap);        
        
        Map<String, KS_Solucion_prescrita__c> lineasPrescritasMap = new Map<String, KS_Solucion_prescrita__c>();
        List<KS_Solucion_prescrita__c> prescritasLST = [SELECT ID,Name,KS_Cantidad__c,KS_Obra__c,KS_Ficha__c,KS_Producto__c,KS_Prescrito__c
                                                         FROM KS_Solucion_prescrita__c 
                                                         WHERE KS_Producto__c IN :prodIDlst AND KS_Obra__c IN :obrasList];
        for (KS_Solucion_prescrita__c sp : prescritasLST) {            
            lineasPrescritasMap.put(sp.KS_Obra__c + '' + sp.KS_Producto__c, sp);
        }
        System.debug('----------------------------------------JCAR - ' + lineasPrescritasMap.size() + ' lineasPrescritasMap : ' + lineasPrescritasMap);
        
        for (OpportunityLineItem opLi : lineasOferta ) {

            if (opLi.KS_Obra__c == null) { continue; }
            String keyID = opLi.KS_Obra__c + '' + opLi.Product2Id;
            
            //System.debug('----------------------------------------JCAR - OBRA : ' + opLi.KS_Obra__c + ' -  PRODUCTO : ' + opLi.Product2Id);
            
            Decimal quantPro = 0; Decimal quantPre = 0;
            KS_Solucion_propuesta__c spro = new KS_Solucion_propuesta__c();
            KS_Solucion_prescrita__c spre = new KS_Solucion_prescrita__c();
            Boolean containsProdPro = lineasPropuestasMap.containsKey(keyID);
            Boolean containsProdPre = lineasPrescritasMap.containsKey(keyID);
            
            if (containsProdPro) {                
                spro = lineasPropuestasMap.get(keyID); //Existe = Update
                // Si se prescribe un mismo producto, la cantidad mayor prescrita es la que siempre PREVALECERÁ
                quantPro = spro.KS_Cantidad__c;
            }            
            
            if (containsProdPre) {                
                spre = lineasPrescritasMap.get(keyID); //Existe = Update
                // Si se prescribe un mismo producto, la cantidad mayor prescrita es la que siempre PREVALECERÁ
                quantPre = spre.KS_Cantidad__c;
            }
            
            //System.debug('----------------------------------------JCAR - EXISTE propuesta? ' + containsProdPro);
            //System.debug('----------------------------------------JCAR - EXISTE prescrita? ' + containsProdPre);
            
            KS_Organizacion_Producto__c oP = 
                orgProductos.containsKey(opLi.Product2Id) ? orgProductos.get(opLi.Product2Id) : null;
            // SOLUCIÓN PROPUESTA
            if (opLi.Quantity > quantPro) {
                spro = createSolPropuesta(spro, opLi, containsProdPro, oP);
                lineasPropuestasMap.put(keyID, spro);
            }
            
            // SOLUCIÓN PRESCRITA
            if (opLi.Quantity > quantPre && opLi.KS_Prescrito__c) {
                spre = createSolPrescrita(spre, opLi, containsProdPre, oP);
                lineasPrescritasMap.put(keyID, spre);
            }
        }
        
        System.debug('-- JCAR ---------------------------------- - UPSERT ' + lineasPropuestasMap.size() + ' KS_Solucion_propuesta__c - ' + lineasPropuestasMap);
        upsert lineasPropuestasMap.values();
        System.debug('-- JCAR ---------------------------------- - UPSERT ' + lineasPrescritasMap.size() + ' KS_Solucion_prescrita__c - ' + lineasPrescritasMap);
        upsert lineasPrescritasMap.values();/*
        System.debug('-- JCAR ---------------------------------- - DELETE ' + lineasDesPrescritas.size() + ' KS_Solucion_prescrita__c - ' + lineasDesPrescritas);
        delete lineasDesPrescritas;*/
        
    }

    public static KS_Solucion_propuesta__c createSolPropuesta(KS_Solucion_propuesta__c spro, OpportunityLineItem opLi, Boolean containsProd, KS_Organizacion_Producto__c oP)  {
        spro = spro != null ? spro : new KS_Solucion_propuesta__c();
        spro.KS_Oferta__c = opLi.OpportunityId;
        spro.KS_Producto__c = opLi.Product2Id;
        spro.KS_Cantidad__c = opLi.Quantity;
        spro.KS_Descuento_neto__c = opLi.KS_Descuento_neto__c;
        spro.KS_Dto_adicional_1__c = opLi.KS_Dto_adicional_1__c;
        spro.KS_Dto_adicional_2__c = opLi.KS_Dto_adicional_2__c;
        spro.KS_Dto_base_1__c = opLi.KS_Dto_base_1__c;
        spro.KS_Dto_base_2__c = opLi.KS_Dto_base_2__c;
        spro.KS_Dto_cliente_final__c = opLi.KS_Dto_cliente_final__c;
        spro.KS_Dto_Instalador__c = opLi.KS_Dto_Instalador__c;
        spro.KS_Dto_logistico__c = opLi.KS_Dto_logistico__c;
        spro.KS_Ficha__c = opLi.KS_Ficha__c;
        spro.KS_Precio__c = opLi.UnitPrice;
        spro.KS_Precio_Neto__c = opLi.KS_Neto_Unitario__c;
        if (!containsProd) {
            spro.KS_Obra__c = opLi.KS_Obra__c;
        }
        if (oP != null) {
            spro.KS_Serie_Gama__c = oP.KS_Serie_Gama__c;
            spro.KS_SubSerie__c = oP.KS_SubSerie__c;
        }
        return spro;
    }
    
    public static KS_Solucion_prescrita__c createSolPrescrita(KS_Solucion_prescrita__c spre, OpportunityLineItem opLi, Boolean containsProd, KS_Organizacion_Producto__c oP)  {
        spre = spre != null ? spre : new KS_Solucion_prescrita__c();
        spre.KS_Oferta__c = opLi.OpportunityId;
        spre.KS_Producto__c = opLi.Product2Id;
        spre.KS_Cantidad__c = opLi.Quantity;
        spre.KS_Descuento_neto__c = opLi.KS_Descuento_neto__c;
        spre.KS_Dto_adicional_1__c = opLi.KS_Dto_adicional_1__c;
        spre.KS_Dto_adicional_2__c = opLi.KS_Dto_adicional_2__c;
        spre.KS_Dto_base_1__c = opLi.KS_Dto_base_1__c;
        spre.KS_Dto_base_2__c = opLi.KS_Dto_base_2__c;
        spre.KS_Dto_cliente_final__c = opLi.KS_Dto_cliente_final__c;
        spre.KS_Dto_Instalador__c = opLi.KS_Dto_Instalador__c;
        spre.KS_Dto_logistico__c = opLi.KS_Dto_logistico__c;
        spre.KS_Ficha__c = opLi.KS_Ficha__c;
        spre.KS_Precio__c = opLi.UnitPrice;
        spre.KS_Precio_Neto__c = opLi.KS_Neto_Unitario__c;
        spre.KS_Prescrito__c = opLi.KS_Prescrito__c;
        if (!containsProd) {
            spre.KS_Obra__c = opLi.KS_Obra__c;
        }
        if (oP != null) {
            spre.KS_Serie_Gama__c = oP.KS_Serie_Gama__c;
            spre.KS_SubSerie__c = oP.KS_SubSerie__c;
        }
        return spre;
    }
}