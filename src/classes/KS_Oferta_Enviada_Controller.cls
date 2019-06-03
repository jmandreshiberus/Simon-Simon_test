global without sharing class KS_Oferta_Enviada_Controller {
    
    public Opportunity oferta {get;set;}
    public KS_Oferta_pendiente__c ofertaPendiente {get;set;}

    public KS_Oferta_Enviada_Controller(ApexPages.StandardController controller) {
        
        String ofertaID = ApexPages.currentPage().getParameters().get('oferta');
        if (ofertaID != null && ofertaID != '') {
            
        	oferta = [SELECT ID, KS_Obra__c FROM Opportunity WHERE ID = :ofertaID];
        }
        
        ofertaPendiente = new KS_Oferta_pendiente__c();
        ofertaPendiente.KS_Oferta__c = oferta.ID;
        ofertaPendiente.KS_Obra__c = oferta.KS_Obra__c;
    }
    
    public PageReference cancel() {
        PageReference pageRef = new PageReference( '/apex/KS_Oferta?id=' + oferta.Id);
        pageRef.SetRedirect(true);
        System.debug('----------------------------------------SERG - pageRef : ' + pageRef );
        return pageRef;
    }    

    public PageReference save() {
        if (ofertaPendiente == null) { return null; }
        System.Approval.unlock(oferta);
        System.debug('-- JCAR ---------------------------------- - ofertaPendiente ' + ofertaPendiente);
        try {
            insert ofertaPendiente;
            System.Approval.lock(oferta);
            PageReference pageRef = new PageReference( '/apex/KS_Oferta_PDF?id=' + ofertaPendiente.ID );
            pageRef.SetRedirect(true);
            System.debug('----------------------------------------SERG - pageRef : ' + pageRef );
            return pageRef;
        } catch (Exception e) {
            ApexPages.addMessages(e);
            return null;
        }
    }
}