public without sharing class KS_OfertasObra_Controller {

    public KS_Obra__c obra {get;set;}
    public List<Oferta> ofertas {get;set;}
    private List<Opportunity> oppLst {get;set;}
    public Boolean getHaveOfertas() {
        return ofertas != null && !ofertas.isEmpty();
    }
    public String getOfertaKeyPrefix() {
        Schema.DescribeSObjectResult R = Opportunity.SObjectType.getDescribe();
        return R.getKeyPrefix();
    }
    public String newOfertaURL {get;set;}
    
    public KS_OfertasObra_Controller(ApexPages.StandardController controller) {
        
        obra = (KS_Obra__c)controller.getRecord();
        if (obra.ID != null) {
            obra = [SELECT ID, Name, CurrencyISOCode FROM KS_Obra__c WHERE ID = :obra.ID];
            // Nombre oferta, nombre cuenta, fecha cierre, contab, etapa, subetapa, importe, aprobación, nivel aprob
            oppLst = [SELECT ID, KS_Oferta_ID__c, Name, CloseDate, KS_Contabiliza__c, StageName, KS_Subetapa__c, KS_Aprobado__c, KS_Protected__c, 
                      KS_Importe_total_fichas__c, KS_Estado_de_aprobacion__c, KS_Nivel_de_aprobacion_de_4__c, KS_Creador_Name__c,
                      KS_Distribuidor__c, KS_Distribuidor__r.Name, KS_Instalador__c, KS_Instalador__r.Name, KS_Cliente_final__c, KS_Cliente_final__r.Name, 
                      KS_Agente_de_contabilizacion__c
                      FROM Opportunity WHERE KS_Obra__c = :obra.ID];
            
            System.debug('-- JCAR ---------------------------------- - KS_OfertasObra_Controller.ofertas? ' + oppLst.size() + ' - ' + oppLst);
            
            ofertas = new List<Oferta>();
            for (Opportunity opp : oppLst) {
                Oferta ofer = new Oferta(opp, obra);
                ofertas.add(ofer);
            }
            
            System.debug('-- JCAR ---------------------------------- - KS_OfertasObra_Controller.ofertas? ' + ofertas.size() + ' - ' + ofertas);
            
            newOfertaURL = '/setup/ui/recordtypeselect.jsp?ent=Opportunity&retURL=%2F' + obra.ID;
            newOfertaURL += '&save_new_url=%2F' + getOfertaKeyPrefix();
            newOfertaURL += '%2Fe%3FCF00N58000009JIpt%3D' + String.escapeSingleQuotes(obra.Name);
			newOfertaURL += '%26CF00N58000009JIpt_lkid%3D' + obra.ID;
            newOfertaURL += '%26retURL%3D%252F' + obra.ID;
        }
    }
    
    public Class Oferta {
        
        public String idopp {get;set;}
        public String cod {get;set;}
        public String name {get;set;}
        public String fecha {get;set;}
        public Boolean protegido {get;set;}
        public Boolean contabiliza {get;set;}
        public String contabilizador {get;set;}
        public String contabilizadorName {get;set;}
        public String contabilizadorID {get;set;}        
        public String etapa {get;set;}
        public String subetapa {get;set;}
        public String importe {get;set;}
        public Boolean aprobacion {get;set;}
        public String aprobacionNivel {get;set;}
        public String creator {get;set;}

        public Oferta(Opportunity opp, KS_Obra__c obra) {
            
            idopp = opp.ID;
            cod = opp.KS_Oferta_ID__c;
            name = opp.Name;
            fecha = opp.CloseDate.format();
            protegido = opp.KS_Protected__c;
            contabiliza = opp.KS_Contabiliza__c;
            etapa = opp.StageName;
            subetapa = opp.KS_Subetapa__c;
            importe = obra.CurrencyISOCode + ' ' + opp.KS_Importe_total_fichas__c.format();
            aprobacion = opp.KS_Aprobado__c;
            aprobacionNivel = opp.KS_Nivel_de_aprobacion_de_4__c.format().split(',')[0];
            creator = opp.KS_Creador_Name__c;
            contabilizador = opp.KS_Agente_de_contabilizacion__c;        
            
            if (contabilizador == 'Distribuidor' && opp.KS_Distribuidor__c != null) {
                contabilizadorID = opp.KS_Distribuidor__c;
                contabilizadorName = opp.KS_Distribuidor__r.Name;
                
            } else if (contabilizador == 'Instalador' && opp.KS_Instalador__c != null) {
                contabilizadorID = opp.KS_Instalador__c;
                contabilizadorName = opp.KS_Instalador__r.Name;
                
            } else if (contabilizador == 'Cliente final' && opp.KS_Cliente_final__c != null) {
                contabilizadorID = opp.KS_Cliente_final__c;
                contabilizadorName = opp.KS_Cliente_final__r.Name;
            }
        }
    }
    
    public /*PageReference*/void gotoNewOferta() {
        return;//  null;
        PageReference pr = new PageReference('/' + getOfertaKeyPrefix() + '/e');
        pr.getParameters().put('Id','theId');
        pr.setRedirect(true);
        //return pr;
    }
}