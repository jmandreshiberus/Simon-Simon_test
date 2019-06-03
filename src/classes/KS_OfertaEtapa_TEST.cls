@isTest
public class KS_OfertaEtapa_TEST {

    public static testMethod void TEST_KS_OfertaEtapa() {
        
        KS_Trigger_Test.disableTrigger();
        KS_Trigger_Test.Test_Data data = KS_Trigger_Test.testTrigger();
        KS_Trigger_Test.enableTrigger();
        
        Test.startTest();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(data.opp);
        KS_OfertaEtapa_Controller control = new KS_OfertaEtapa_Controller(sc);
        KS_OfertaEtapa_Controller.getIsAdmin();
        control.getHaveErrorOferta();
        control.getContabilizaDistribuidor();
        control.getPrescribeDistribuidor();
        control.reload();
        
        control.oferta.KS_Agente_de_contabilizacion__c = 'Cliente final'; control.reload();
        control.oferta.KS_Agente_de_contabilizacion__c = 'Distribuidor'; control.reload();
        control.oferta.KS_Agente_de_contabilizacion__c = 'Instalador'; control.reload();
        
        control.editEtapaOferta();
        control.cancel();
    }
}