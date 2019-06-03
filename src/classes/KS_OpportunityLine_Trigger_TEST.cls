@isTest
public class KS_OpportunityLine_Trigger_TEST {

    public static testMethod void TEST_KS_OpportunityLine_Trigger() {
        Map<String, OpportunityLineItem> prodOfertaMAP = KS_Oferta_AddProductos_Test.test();
        KS_Organizacion_Producto__c oP = new KS_Organizacion_Producto__c();
        oP.KS_Serie_Gama__c = '001'; oP.KS_Subserie__c  = '001';
        if (!prodOfertaMAP.isEmpty()) {
            for (OpportunityLineItem oppLinIt : prodOfertaMAP.values()) {
                Boolean containsProd = oppLinIt.KS_Obra__c == null;
                KS_OpportunityLine_Trigger.createSolPrescrita(null, oppLinIt, containsProd, oP);
                KS_OpportunityLine_Trigger.createSolPropuesta(null, oppLinIt, containsProd, oP);
            }
        }
    }
}