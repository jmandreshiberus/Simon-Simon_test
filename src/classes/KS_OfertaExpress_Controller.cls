global with sharing class KS_OfertaExpress_Controller {
	
    public KS_Oferta_express__c oferta {get;set;} // Objeto principal
    public KS_OfertaExpress_Controller(ApexPages.StandardController controller) {
        
        oferta = (KS_Oferta_express__c)controller.getRecord();
        // SELECT Id, KS_Dto_Cliente_final__c, KS_Dto_Instalador__c, KS_Dto_adicional_1__c, KS_Dto_adicional_2__c, KS_Dto_base_1__c, KS_Dto_base_2__c, KS_Importe_bruto__c, KS_Importe_neto__c FROM KS_Oferta_express__c
        if (oferta.ID!=null) {
            oferta = [SELECT Id, KS_Dto_Cliente_final__c, KS_Dto_Instalador__c, KS_Dto_adicional_1__c, KS_Dto_adicional_2__c, 
                      KS_Dto_base_1__c, KS_Dto_base_2__c, KS_Importe_bruto__c, KS_Importe_neto__c, KS_Dto_total__c, KS_Margen__c,
                      KS_Importe_clientefinal__c, KS_Importe_instalador__c
                      FROM KS_Oferta_express__c];
        }
    }
}