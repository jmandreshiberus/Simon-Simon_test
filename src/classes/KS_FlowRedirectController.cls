public with sharing class KS_FlowRedirectController {
    
    public Event evento {get;set;}
    public final Flow.Interview.NewReport report {get; set;}
    
    public Boolean getNotHaveRep() { return !getHaveRep(); }
    public Boolean getHaveRep() {
        /*if (evento.KS_Reporte_asociado__c != null) {
            reportAlert = reportAlert != '' ? reportAlert : 'Reporte creado.';
            gotoURL = evento.KS_Reporte_asociado__c;
            return true;
        }*/
        if (report != null && report.IdCreatedReport != null) {
            reportAlert = reportAlert != '' ? reportAlert : 'Reporte creado.';
            gotoURL = report.IdCreatedReport;
            return true;
        }        
        return false;
    }
    
    public String reportAlert {get;set;}
    public String gotoURL {get;set;}
    
    public KS_FlowRedirectController(ApexPages.StandardController controller) {
        evento = (Event)controller.getRecord();
        evento = [SELECT ID, KS_Reporte_asociado__c, CurrencyIsoCode, RecordTypeId FROM Event WHERE ID = :evento.ID];
        reportAlert = evento.KS_Reporte_asociado__c != null ? 'Reporte ya existente.' : '';
        gotoURL = evento.KS_Reporte_asociado__c != null? evento.KS_Reporte_asociado__c : evento.ID;
    }
    
    public String getFinishLoc() {
        
        evento = [SELECT ID, KS_Reporte_asociado__c, CurrencyIsoCode, RecordTypeId FROM Event WHERE ID = :evento.ID];
        if (report != null) {

            System.debug('-- JCAR ---------------------------------- - getFinishLoc() - evento? ' + evento);
            gotoURL = report==null? 'home/home.jsp' : (report.IdCreatedReport==null? evento.ID : report.IdCreatedReport);
                
        } else { if ( evento.KS_Reporte_asociado__c != null ) { return evento.KS_Reporte_asociado__c; } }
        return gotoURL;
    }
    public PageReference getRedirect(){
        PageReference pageRef = new PageReference('/' + getfinishLoc());
        pageRef.setRedirect(true);
        return pageRef;
    }
}