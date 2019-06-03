@isTest
public class KS_BATCH_Test {

    public static testMethod void testSetCliente(){
        
        KS_Trigger_Test.disableTrigger();
        List<Account> a = KS_INT_SAP_TEST.createCuentaSAP(true, 'TESTCLIENT');
        if (a.isEmpty()) {return;}
        
        //System.debug(Logginglevel.ERROR,'-- TEST ------------------------------ JCAR Account -- ' +  a.get(0));
        KS_Organizacion_Cliente__c o1 = [SELECT ID, KS_ID_Organizacion_Cliente__c,
                                         KS_Organizacion_de_ventas__c, KS_Canal_de_distribucion__c, 
                                         KS_Sector_Distribuidor__c, KS_Oficinas_de_ventas__c, 
                                         KS_Sociedad__c, KS_Lista_de_precios__c, KS_Grupo_de_vendedores__c, 
                                         KS_Cliente_Distribucion__c, KS_Cliente_Dest_Mercancias__c, KS_Cliente_solicitante__c
                                         FROM KS_Organizacion_Cliente__c WHERE KS_Cliente_Distribucion__c = :a.get(0).ID];
        //System.debug(Logginglevel.ERROR,'-- TEST ------------------------------ JCAR KS_Organizacion_Cliente__c -- ' +  o1);

        KS_TEST_FUNCTIONS tstfnc = new KS_TEST_FUNCTIONS();
        Map<String, ID> rtM = KS_TEST_FUNCTIONS.getRecordTypeStatic();
        KS_Obra__c obr = tstfnc.createObra(rtM);
        Account acc = a.get(0);
        KS_Estructura_Geografica__c ege =  tstfnc.createEstructuraGeografica(acc);

        KS_Organizacion_Cliente__c org = o1;
        org.KS_Area__c = ege.KS_Area__c;
        org.KS_Delegacion__c = ege.KS_Delegacion__c;
        org.KS_Zona__c = ege.KS_Zona__c;
        org.KS_ID_Organizacion_Cliente__c = 'LA-ID-SE-HA-ROTO-SIN-QUERER';
        update org;
        
        Pricebook2 pbS = tstfnc.createPricebook();
        KS_Usuario_MarcaArea__c uma = tstfnc.createUserArea(org);
        Opportunity opp = tstfnc.createOferta(acc, org, obr, pbS);
        
        /*System.debug(Logginglevel.ERROR,'-- TEST ------------------------------ JCAR CALL KS_Batch_RepairOrgCliente con 1 ORG');
        
        KS_Batch_RepairOrgCliente.logic(a);
        
        org.KS_ID_Organizacion_Cliente__c = 'LA-ID-SE-HA-ROTO-SIN-QUERER';
        update org;*/
        
        KS_Organizacion_Cliente__c o2 = org.clone(false,false,false,false);
        o2.KS_ID_Organizacion_Cliente__c = 'LA-ID-SE-HA-CARGADO-MAL';
        o2.KS_Scoring_Actividad__c = '***';
        o2.KS_Scoring_Negocio__c = '***';
        o2.KS_Scoring_IF__c = 'AB';
        o2.KS_Recurrencia__c = '90';
        insert o2;
        KS_Trigger_Test.enableTrigger();
        
        //System.debug(Logginglevel.ERROR,'-- TEST ------------------------------ JCAR CALL KS_Batch_RepairOrgCliente con 2 ORG (DUPLICADOS)');
        
        List<KS_Organizacion_Cliente__c> orgUpdate = KS_Batch_RepairOrgCliente.logic(a);
        //update orgUpdate;
        
        List<KS_Organizacion_Cliente__c> orgR = [SELECT ID, KS_ID_Organizacion_Cliente__c, KS_Recurrencia__c, OwnerID,
                                                 KS_Cliente_Distribucion__c, KS_Cliente_solicitante__c, KS_Cliente_Dest_Mercancias__c,
                                                 KS_Id_Salesforce_Distribuidor__c, KS_Id_Salesforce_Solicitante__c, KS_Id_Salesforce_Destinatario__c,
                                                 KS_Organizacion_de_ventas__c, KS_Oficinas_de_ventas__c, KS_Canal_de_distribucion__c, KS_Sector_Distribuidor__c,
                                                 KS_Scoring_Actividad__c, KS_Scoring_Negocio__c, KS_Scoring_IF__c
                                                 FROM KS_Organizacion_Cliente__c WHERE KS_Cliente_Distribucion__c = :acc.ID];
        System.debug(Logginglevel.ERROR,'-- TEST FINAL RESULT ------------------------------ JCAR KS_Organizacion_Cliente__c -- ' +  orgR);
    }
}