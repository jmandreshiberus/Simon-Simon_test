@isTest
public class KS_Oferta_TEST {

    @testSetup static void TEST_SETUP_KS_Oferta() {
        
        KS_Trigger_Test.disableTrigger();
        KS_Trigger_Test.testTrigger();
        Opportunity opp = [SELECT ID,KS_Distribuidor__c,KS_Organizacion_Cliente__c,KS_Organizacion__c,KS_Obra__c,Pricebook2Id FROM Opportunity LIMIT 1];
        
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        KS_Oferta_AddProductos_Controller oppAddProdCTRL = new KS_Oferta_AddProductos_Controller(sc);
        oppAddProdCTRL.productosADD = 4; oppAddProdCTRL.callAddProductos(); // lanzamos añadido de lineas
        oppAddProdCTRL.callAddFicha(); // lanzamos añadido de ficha nueva
        
        // AÑADIR PRODUCTO "PRODTEST1234"
        oppAddProdCTRL.productoLookup = [SELECT ID FROM Product2 LIMIT 1].ID;
        for (String k : oppAddProdCTRL.productosOferta.keySet()) { oppAddProdCTRL.productoIDROW = k; break; }
        oppAddProdCTRL.callDatosProducto();
        KS_Trigger_Test.enableTrigger();
    }
    
    public static testMethod void TEST_KS_Oferta() {
        
        KS_Trigger_Test.disableTrigger();
        Opportunity opp = [SELECT ID,KS_Distribuidor__c,KS_Organizacion_Cliente__c,KS_Organizacion__c,KS_Obra__c,Pricebook2Id FROM Opportunity LIMIT 1];
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        KS_Oferta_Controller control = new KS_Oferta_Controller(sc);
        control.fichaToEdit = 1;

        control.getEditOferta();
        control.getHasProductos();
        control.getFichas();
        control.getHaveOfertasPendientes();
        control.getPendientes();
        control.getCompetencias();
        control.getHaveEdit();
        control.getHaveErrorOferta();
        control.getHaveErrorFicha();
        control.getValidUser();
        control.getAdminUser();
        control.getOwnerUser();
        control.getManagerUser();
        control.getSubmitted();
        control.getApproval();
        control.getClosed();
        control.getLocked();
        control.getTerritorio();
        control.getOfertaRT();
        control.getGroupValid();
        control.enableEdit();
        control.validClienteOferta();
        control.setAgenteOferta();
        control.getOrgClienteByClienteID(opp.KS_Distribuidor__c);
        
        KS_Oferta_Controller.format2Decimal(1.1);
        KS_Trigger_Test.enableTrigger();
    }
    
    public static testMethod void TEST_KS_Oferta_fichas() {
        
        KS_Trigger_Test.disableTrigger();
        Opportunity opp = [SELECT ID,KS_Distribuidor__c,KS_Organizacion_Cliente__c,KS_Organizacion__c,KS_Obra__c,Pricebook2Id FROM Opportunity LIMIT 1];
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        KS_Oferta_Controller control = new KS_Oferta_Controller(sc);
        control.fichaToEdit = 1;

        control.save();
        control.saveFichas();
        control.addProducts();
        control.addProductsToFicha();
        control.duplicar();
        control.deleteFicha();
        control.setProductosFromOferta();
        control.setOfertasPendientes();
        control.cancelFichas();
        control.cancel();
        control.editMode();
        control.gotoPDF();
        control.setVariedadVolumenToProducto(new Set<ID>());
        control.unlock();
        control.editEtapaOferta();
        control.calculateCondicionesComerciales();
        control.resetCondicionProducto(new OpportunityLineItem());
        control.gotoDEMO();
        control.reload();
        control.getPrescribeDistribuidor();
        KS_Trigger_Test.enableTrigger();
    }
    
    public static testMethod void TEST_KS_Oferta_sendApproval() {
        
        KS_Trigger_Test.disableTrigger();
        Opportunity opp = [SELECT ID,KS_Distribuidor__c,KS_Organizacion_Cliente__c,KS_Organizacion__c,KS_Obra__c,Pricebook2Id FROM Opportunity LIMIT 1];
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        KS_Oferta_Controller control = new KS_Oferta_Controller(sc);
        control.fichaToEdit = 1;
        for (List<OpportunityLineItem> prodL : control.productosOferta.values()) {
            for (OpportunityLineItem prod : prodL) {
                prod.KS_Dto_adicional_2__c = 10;
                prod.KS_Material_sin_cargo__c = true;
            }
        }
        control.sendApproval();
        KS_Trigger_Test.enableTrigger();
    }
}