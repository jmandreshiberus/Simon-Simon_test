global without sharing class KS_LeadAccountApproval_Controller {

    public Account lead {get;set;}

    public Boolean error {get;set;}
    public String errorMSG {get;set;}
    
    public String url {get;set;}
    public Boolean getRedirect() {
        return url != null && url != '';
    }
    
    public Boolean sendToApprove {get;set;}
    
    public KS_LeadAccountApproval_Controller(ApexPages.StandardController controller) {
        
        sendToApprove = false;
        
        lead = (Account)controller.getRecord();
        if (lead!=null && lead.ID!=null) {
            
            Map<String,ID> recordTypes = new Map<String,ID>();
            List<RecordType> rtLst = [SELECT ID,DeveloperName FROM RecordType];
            for (RecordType rt : rtLst) {
                recordTypes.put(rt.DeveloperName, rt.ID);
            }
            
            lead = [SELECT ID, KS_Canal_SAP__c, KS_Sector_SAP__c, KS_Organizaciones_de_cuentas__c, RecordTypeID 
                    FROM Account WHERE ID = :lead.ID];
            if (lead.RecordTypeID != recordTypes.get('KS_Lead')) { // ERROR: Cuenta no tipo lead
                error = true;
                errorMSG = 'ERROR: Account not Lead type';
                url = '';
                return;
            }
            
            if (lead.KS_Organizaciones_de_cuentas__c != null && lead.KS_Organizaciones_de_cuentas__c != '') {
                
                String aprov = ApexPages.currentPage().getParameters().get('send');
                sendToApprove = aprov != null && aprov == 'true';
                //calcularAprobacion();
                //update lead;
            
            } else { // ERROR: No está listo para ser aprobado, redirect a página de cuenta
                error = true;
                errorMSG = 'ERROR: Account not prepared to approve';
            }

        } else { // ERROR: No existe la cuenta, redirect a página de lista de cuentas
            error = true;
            errorMSG = 'ERROR: Account not found';
            url = '';
            return;
        }
        
        error = false;
        //url = '/'+lead.ID;
    }
    
    public void calcularAprobacion() {
		
        Map<String,ID> terrType = new Map<String,ID>();
        List<Territory2Type> terrLst = [SELECT ID, DeveloperName FROM Territory2Type];
        for (Territory2Type tp : terrLst) {
            terrType.put(tp.DeveloperName, tp.ID);
        }
        
        List<String> orgVentas = new List<String>();
        String area = '';
        
        List<KS_Organizacion_Cliente__c> ocLst = [SELECT ID,KS_Area__c,KS_Organizacion_de_Ventas__c
                                                  FROM KS_Organizacion_Cliente__c
                                                  WHERE KS_Cliente_Distribucion__c = :lead.ID];
        for (KS_Organizacion_Cliente__c oc : ocLst) {
            orgVentas.add(oc.KS_Organizacion_de_Ventas__c);
            area = oc.KS_Area__c;
        }
        
        List<UserTerritory2Association> utaLst = 
            [SELECT Id, UserId, Territory2Id, RoleInTerritory2, 
             Territory2.KS_Organizacion_Ventas__c
             FROM UserTerritory2Association 
             WHERE RoleInTerritory2 = 'JAR'
             AND Territory2.KS_Organizacion_Ventas__c IN :orgVentas
             AND Territory2.KS_Canal__c = :lead.KS_Canal_SAP__c
             AND Territory2.KS_Sector_Distribuidor__c = :lead.KS_Sector_SAP__c
             AND Territory2.KS_Area__c = :area
             AND Territory2.Territory2TypeId = :terrType.get('KS_Area')
            ];
        System.debug('----------------------------------------JCAR - ' + utaLst.size() + ' UserTerritory2Association : ' + utaLst);
        for (UserTerritory2Association uta : utaLst) {
            
            String marca = uta.Territory2.KS_Organizacion_Ventas__c;
            ID responsable = uta.UserId;
            if (marca == 'SI10') { lead.KS_Responsable_SI10__c = responsable; }
            if (marca == 'FL31') { lead.KS_Responsable_FL31__c = responsable; }
            if (marca == 'IE20') { lead.KS_Responsable_IE20__c = responsable; }            
        }
        //ID responsable = terrOferta.size()>0 ? terrOferta.get(0).UserId : null;
        
        update lead;
        error = false;
        url = '/'+lead.ID;
        
        if (sendToApprove) {
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Submitted for approval. Please approve.');
            req.setObjectId(lead.ID);
            Approval.ProcessResult result = Approval.process(req);            
        }
    }
}