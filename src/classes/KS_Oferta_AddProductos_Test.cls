@isTest
public class KS_Oferta_AddProductos_Test {
    
    public static testmethod Map<String, OpportunityLineItem> test()
    {
        KS_Trigger_Test.disableTrigger();
        KS_Trigger_Test.testTrigger();
        Opportunity opp = [SELECT ID FROM Opportunity limit 1];
        Product2 prd = [SELECT ID FROM Product2 limit 1];
       
        // forzamos cálculo de PriceBook
        opp.Pricebook2Id = null; update opp;
        KS_Trigger_Test.enableTrigger();
        
        Test.startTest();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        KS_Oferta_AddProductos_Controller oppAddProdCTRL = new KS_Oferta_AddProductos_Controller(sc);
        oppAddProdCTRL.productosADD = 4; oppAddProdCTRL.callAddProductos(); // lanzamos añadido de lineas
        oppAddProdCTRL.callAddFicha(); // lanzamos añadido de ficha nueva
        
        // AÑADIR PRODUCTO "PRODTEST1234"
        oppAddProdCTRL.productoLookup = [SELECT ID FROM Product2 WHERE KS_ID_SAP__C = 'PRODTEST4321'].ID;
        for (String k : oppAddProdCTRL.productosOferta.keySet()) { oppAddProdCTRL.productoIDROW = k; break; }
        oppAddProdCTRL.callDatosProducto();
        
        Test.stopTest();
        
        return oppAddProdCTRL.productosOferta;
    }
}