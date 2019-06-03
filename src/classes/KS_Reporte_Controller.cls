global without sharing class KS_Reporte_Controller {

    public Event evento {get;set;}
    public String getStrDate() {
        if (evento.StartDateTime == null) {return '';}
        return formatDate(evento.StartDateTime);
    }
    public String getEndDate() {
        if (evento.EndDateTime == null) {return '';}
        return formatDate(evento.EndDateTime);
    }
    private String formatDate(DateTime dt) {
        String dts = '';
        dts = dt.format('dd/MM/YYYY kk:mm').replaceAll(' ', '%20').replaceAll('/', '%2F').replaceAll(':', '%3A');
        return dts;
    }
    
    public KS_Reporte_Controller(ApexPages.StandardController controller) {
        
        //var URL = '/a0V/e?retURL=%2Fa0V%2Fo&CF00N58000009KaHe_lkid={!evento.Who}&CF00N58000009KaHe={!evento.Who}
        //&CF00N3E000000b3wW_lkid={!evento.WhatId}&CF00N3E000000b3wW={!evento.What.Name}
        //&CF00N58000009KaHh_lkid={!evento.KS_ObraId__c}
        //&CF00N58000009KaHh={!evento.KS_Obra__c}&CF00N58000009KaHi_lkid={!evento.KS_OfertaId__c}&CF00N58000009KaHi={!evento.KS_Oferta__c}
        //&00N58000009KaHg_lkid={!evento.StartDateTime+0}&00N58000009KaHg={!evento.StartDateTime+0}&00N5800000BDF9W_lkid={!evento.Subject}
        //&00N5800000BDF9W={!evento.Subject}&00N58000009KaHf_lkid={!evento.EndDateTime+0}&00N58000009KaHf={!evento.EndDateTime+0}
        //&00N58000009KaHd_lkid={!evento.Description}&00N58000009KaHd={!evento.Description}&00N5800000BDF9g_lkid={!evento.KS_Objetivo_de_la_visita__c}
        //&00N5800000BDF9g={!evento.KS_Objetivo_de_la_visita__c}&CF00N5800000AiNH8_lkid={!evento.KS_CampanaId__c}&CF00N5800000AiNH8={!evento.KS_Campana__c}
        //&00N58000009KaHk_lkid={!evento.KS_Tipo_de_visita__c}&00N58000009KaHk={!evento.KS_Tipo_de_visita__c}';
        
        evento = (Event)controller.getRecord();
        if (evento != null && evento.ID != null) {
            evento = [SELECT ID, WhoId, Who.Name, WhatId, What.Name, 
                      KS_ObraId__c, KS_Obra__c, KS_Obra__r.Name, KS_OfertaId__c, KS_Oferta__c, KS_Oferta__r.Name,
                      StartDateTime, Subject, EndDateTime, Description, KS_Objetivo_de_la_visita__c, 
                      KS_CampanaId__c, KS_Campana__c, KS_Tipo_de_visita__c
                      FROM Event WHERE ID = :evento.ID];
            evento.Description = evento.Description != null ? evento.Description.replaceAll(' ', '%20') : '';
            evento.KS_Objetivo_de_la_visita__c = evento.KS_Objetivo_de_la_visita__c != null ? evento.KS_Objetivo_de_la_visita__c.replaceAll(' ', '%20') : '';
        }
    }
}