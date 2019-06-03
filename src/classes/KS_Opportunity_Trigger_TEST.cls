@isTest
public class KS_Opportunity_Trigger_TEST {

    public static testMethod void TEST_KS_Opportunity_Trigger() {
        
        KS_Trigger_Test.disableTrigger();
        KS_Trigger_Test.testTrigger();
        KS_TEST_FUNCTIONS tstfnc = new KS_TEST_FUNCTIONS();
        Opportunity opp = [SELECT ID,KS_Distribuidor__c,KS_Organizacion_Cliente__c,KS_Organizacion__c,KS_Obra__c,Pricebook2Id FROM Opportunity LIMIT 1];
        
        Opportunity opp2 = tstfnc.createOferta(
            new Account(ID=opp.KS_Distribuidor__c), 
            new KS_Organizacion_Cliente__c(ID=opp.KS_Organizacion_Cliente__c,KS_Organizacion_de_ventas__c=opp.KS_Organizacion__c), 
            new KS_Obra__c(ID=opp.KS_Obra__c), 
            new Pricebook2(ID=opp.Pricebook2Id)); // creamos una segunda oferta
        Opportunity oppOLD = opp.clone();
        KS_Trigger_Test.enableTrigger();
        
        Test.startTest();
        
        opp.KS_Contabiliza__c = true;
        opp.KS_Agente_de_contabilizacion__c = 'Distribuidor';
        opp.KS_Prescrito__c = true;   
        opp.KS_Organizacion__c = 'SI10';
        
        opp2.KS_Contabiliza__c = true;
        opp2.KS_Agente_de_contabilizacion__c = 'Distribuidor';
        opp2.KS_Prescrito__c = true;   
        opp2.KS_Organizacion__c = 'SI10';
        UPDATE opp2;
        
        List<sObject> sobjL = new List<sObject>(); sobjL.add(opp);
        List<sObject> sobjLOLD = new List<sObject>(); sobjLOLD.add(oppOLD);
        Map<Id, sObject> sobjM = new Map<Id, sObject>(); sobjM.put(opp.ID,opp);
        Map<Id, sObject> sobjMOLD = new Map<Id, sObject>(); sobjMOLD.put(oppOLD.ID,oppOLD);
        
        KS_Opportunity_Trigger trig = null;
        trig = new KS_Opportunity_Trigger(
            true, true, true, true, true, true, sobjL, sobjM, sobjLOLD, sobjMOLD);
        trig.executeBeforeInsert(); trig.executeAfterInsert(); trig.executeBeforeUpdate(); trig.executeAfterUpdate();   
        trig.callValidClienteOferta(opp);
        trig.getDescarted(opp);
        trig.setUbicacionObra();
        KS_Opportunity_Trigger.cloneOpportunity(opp);
        KS_Opportunity_Trigger.cloneOpportunityLineItem(new OpportunityLineItem(), opp.ID);
        trig.setPriceBookID(opp.Pricebook2Id);
        
        opp2.KS_Protected__c = true;
        UPDATE opp2;
        opp.KS_Protected__c = true;
        oppOLD = opp.clone();
        sobjL = new List<sObject>(); sobjL.add(opp);
        sobjLOLD = new List<sObject>(); sobjLOLD.add(oppOLD);
        sobjM = new Map<Id, sObject>(); sobjM.put(opp.ID,opp);
        sobjMOLD = new Map<Id, sObject>(); sobjMOLD.put(oppOLD.ID,oppOLD);
        trig = new KS_Opportunity_Trigger(
            true, true, true, true, true, true, sobjL, sobjM, sobjLOLD, sobjMOLD);
        trig.executeDuplicate();
    }   
    
    public static testMethod void TEST_KS_Opportunity_Trigger_sincro() {
        
        KS_Trigger_Test.disableTrigger();
        KS_Trigger_Test.testTrigger();
        KS_TEST_FUNCTIONS tstfnc = new KS_TEST_FUNCTIONS();
        Opportunity opp = [SELECT ID,KS_Distribuidor__c,KS_Organizacion_Cliente__c,KS_Organizacion__c,KS_Obra__c,Pricebook2Id FROM Opportunity LIMIT 1];
        Opportunity oppOLD = opp.clone();
        
        Opportunity opp2 = tstfnc.createOferta(
            new Account(ID=opp.KS_Distribuidor__c), 
            new KS_Organizacion_Cliente__c(ID=opp.KS_Organizacion_Cliente__c,KS_Organizacion_de_ventas__c=opp.KS_Organizacion__c), 
            new KS_Obra__c(ID=opp.KS_Obra__c), 
            new Pricebook2(ID=opp.Pricebook2Id)); // creamos una segunda oferta
        
        opp.KS_Contabiliza__c = true;
        opp.KS_Agente_de_contabilizacion__c = 'Distribuidor';
        opp.KS_Prescrito__c = true;   
        opp.KS_Organizacion__c = 'SI10';
        
        opp2.KS_Contabiliza__c = true;
        opp2.KS_Agente_de_contabilizacion__c = 'Distribuidor';
        opp2.KS_Prescrito__c = true;   
        opp2.KS_Organizacion__c = 'SI10';
        UPDATE opp2;
        
        List<sObject> sobjL = new List<sObject>(); sobjL.add(opp);
        List<sObject> sobjLOLD = new List<sObject>(); sobjLOLD.add(oppOLD);
        Map<Id, sObject> sobjM = new Map<Id, sObject>(); sobjM.put(opp.ID,opp);
        Map<Id, sObject> sobjMOLD = new Map<Id, sObject>(); sobjMOLD.put(oppOLD.ID,oppOLD);
        
        KS_Opportunity_Trigger trig = null;
        trig = new KS_Opportunity_Trigger(
            true, true, true, true, true, true, sobjL, sobjM, sobjLOLD, sobjMOLD);
        
        Test.startTest();
        KS_Trigger_Test.enableTrigger();
        
        String sincroKey = opp.KS_Obra__c+opp.KS_Organizacion__c;
        Map<ID,Opportunity> oppUpdate = new Map<ID,Opportunity>();
        Map<String, Boolean> obraContaAgente = new Map<String, Boolean>();
        Map<String,Opportunity> sincroClieFin = new Map<String,Opportunity>();
        Map<String,Opportunity> sincroInstala = new Map<String,Opportunity>();
        Map<String,Opportunity> sincroDistrib = new Map<String,Opportunity>();

        /*String kmarca = 
            (opp.KS_Canal__c != null ? opp.KS_Canal__c : '')
            + (opp.KS_Organizacion_de_ventas__c != null ? opp.KS_Organizacion_de_ventas__c : '') 
            + (opp.KS_Agente_de_contabilizacion__c != null ? opp.KS_Agente_de_contabilizacion__c : '');
        obraContaAgente.put(opp.KS_Obra__c + kmarca, true);*/
        
        sincroInstala.put(sincroKey, opp2);
        sincroClieFin.put(sincroKey, opp2);
        trig.calcSincronizacion(sobjL, oppUpdate, obraContaAgente, sincroClieFin, sincroInstala, sincroDistrib);
        
        sincroClieFin = new Map<String,Opportunity>();
        sincroInstala = new Map<String,Opportunity>();
        
        opp.KS_Agente_de_contabilizacion__c = 'Instalador';
        
        sobjL = new List<sObject>(); sobjL.add(opp);
        sincroDistrib.put(sincroKey, opp2);
        trig.calcSincronizacion(sobjL, oppUpdate, obraContaAgente, sincroClieFin, sincroInstala, sincroDistrib);
        
        sincroDistrib = new Map<String,Opportunity>();
        sincroClieFin.put(sincroKey, opp2);
        trig.calcSincronizacion(sobjL, oppUpdate, obraContaAgente, sincroClieFin, sincroInstala, sincroDistrib);
        
        sincroDistrib = new Map<String,Opportunity>();
        sincroClieFin = new Map<String,Opportunity>();
        sincroInstala = new Map<String,Opportunity>();
        
        opp.KS_Agente_de_contabilizacion__c = 'Cliente final';
        
        sincroDistrib.put(sincroKey, opp2);
        trig.calcSincronizacion(sobjL, oppUpdate, obraContaAgente, sincroClieFin, sincroInstala, sincroDistrib);
        
        sincroDistrib = new Map<String,Opportunity>();
        sincroInstala.put(sincroKey, opp2);
        trig.calcSincronizacion(sobjL, oppUpdate, obraContaAgente, sincroClieFin, sincroInstala, sincroDistrib);
        
        sincroDistrib = new Map<String,Opportunity>();
        sincroClieFin = new Map<String,Opportunity>();
        sincroInstala = new Map<String,Opportunity>();
        trig.calcSincronizacion(sobjL, oppUpdate, obraContaAgente, sincroClieFin, sincroInstala, sincroDistrib);
    }
}