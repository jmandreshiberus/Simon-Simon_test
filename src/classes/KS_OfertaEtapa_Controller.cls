public without sharing class KS_OfertaEtapa_Controller {

    public Opportunity oferta {get;set;}
    public String errorTextOferta {get;set;}
    public Boolean getHaveErrorOferta() {
        return errorTextOferta !=null&&errorTextOferta !='';
    }
    public Boolean getContabilizaDistribuidor() {
        return oferta != null && oferta.KS_Agente_de_contabilizacion__c != null
            && oferta.KS_Agente_de_contabilizacion__c == 'Distribuidor';
    } 
    public Boolean getPrescribeDistribuidor() {
        return oferta != null && getContabilizaDistribuidor() && oferta.KS_Prescrito__c;
    }
    public Boolean yaPrescrito {get;set;}
    
    public KS_OfertaEtapa_Controller(ApexPages.StandardController controller) {
        
        oferta = (Opportunity)controller.getRecord();
        if (oferta.ID != null) {
            oferta = [SELECT ID, Name, StageName, KS_Subetapa__c, KS_Sincronizacion__c,
                      KS_Probabilidad__c, CloseDate, KS_Prescrito__c,
                      KS_Contabiliza__c, KS_Agente_de_contabilizacion__c
                      FROM Opportunity WHERE ID = :oferta.ID];
            yaPrescrito = oferta.KS_Prescrito__c;
        }
    }
    
    public PageReference editEtapaOferta() {
        
        errorTextOferta = '';
        if (getClosed()) { oferta.KS_Contabiliza__c = true; }
        if (oferta.KS_Contabiliza__c && oferta.KS_Agente_de_contabilizacion__c == null) {
            errorTextOferta = 'Error en oferta "'+oferta.Name+'": Debe seleccionarse agente de contabilización.';
            oferta.addError(errorTextOferta);
            return null;
        }
        oferta.KS_Prescrito__c = checkPrescrito();
        
        try {
            
            System.Approval.unlock(oferta, true);
        	update oferta;  
            System.Approval.lock(oferta, true);

        } catch(Exception e) {
            
            errorTextOferta = e.getMessage();
            return null;
        }
        
        return gotoOferta();
    }
    
    public PageReference cancel() {
        return gotoOferta();
    }
    
    private PageReference gotoOferta() {
        PageReference pageRef = new PageReference( '/apex/KS_Oferta?id=' + oferta.Id);
        pageRef.SetRedirect(true);
        return pageRef; 
    }
    
    public Boolean getClosed() {
        return oferta != null && 
            (oferta.StageName.containsIgnoreCase('Adjudicada') ||
             oferta.StageName.containsIgnoreCase('Perdida')
            )
            && !oferta.StageName.containsIgnoreCase('otro Distribuidor');
    }
    
    public void reload(){ 
        System.debug('-- KS_OfertaEtapa RELOAD --');
        oferta.KS_Prescrito__c = checkPrescrito();//oferta.KS_Agente_de_contabilizacion__c == 'Cliente final' || getPrescribeDistribuidor() || yaPrescrito;
    }
    
    public Boolean checkPrescrito() { return oferta != null && oferta.KS_Prescrito__c;/*&& checkPrescritoAgente() && oferta.KS_Contabiliza__c;*/ }
    public Boolean checkPrescritoAgente() {
        if (oferta != null && oferta.KS_Agente_de_contabilizacion__c != null
            && oferta.KS_Agente_de_contabilizacion__c == 'Cliente final') { return true; }
        if (oferta != null && oferta.KS_Agente_de_contabilizacion__c != null
            && oferta.KS_Agente_de_contabilizacion__c == 'Distribuidor') { return oferta.KS_Prescrito__c; }
        if (oferta != null && oferta.KS_Agente_de_contabilizacion__c != null
            && oferta.KS_Agente_de_contabilizacion__c == 'Instalador') { return oferta.KS_Prescrito__c; }
        return false;
    }
    
    public static Boolean getIsAdmin() {
        if (UserInfo.getUserEmail()=='jrius@simon.es') {return true;}
        if (UserInfo.getUserEmail()=='jmarchena@simon.es') {return true;}
        if (UserInfo.getUserEmail()=='psamo@simon.es') {return true;}
        if (UserInfo.getUserEmail()=='customers@kaizenstep.com') {return true;}
        return false;
    }
}