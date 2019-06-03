public without sharing class KS_MarcasCliente_Controller {

    public Account cuenta {get;set;}
    
    public List<KS_Organizacion_Cliente__c> marcas {get;set;}
    public Boolean getHaveMarcas() {
        return marcas != null && !marcas.isEmpty();
    }   
    
    public List<CondicionComercial> condiciones {get;set;}
    public Boolean getHaveCondiciones() {
        return condiciones != null && !condiciones.isEmpty();
    }
    
    public Boolean getIsAdmin() {
        String profName = [Select Name from Profile where Id = :UserInfo.getProfileId()].Name;
        return profName.contains('Admin');
    }
    
    public KS_MarcasCliente_Controller(ApexPages.StandardController controller) {
        
        cuenta = (Account)controller.getRecord();
        if (cuenta.ID != null) {
            
            cuenta = [SELECT ID, KS_recordType_Name__c FROM Account WHERE ID = :cuenta.ID];
            
            // JCAR 170124 - Se crean dos lógicas paralelas, una para Distribuidores (SAP/CRM) y otra para el resto //
            
            if (cuenta.KS_recordType_Name__c == 'KS_Distribuidores_SAP' || cuenta.KS_recordType_Name__c == 'KS_Distribuidores') {
                
                marcas = [SELECT ID, Name, KS_Organizacion_de_ventas__c, KS_Lista_de_precios__c,
                          KS_Canal_de_distribucion__c, KS_Sector_Distribuidor__c,
                          KS_Area__c, KS_Delegacion__c, KS_Zona__c,
                          KS_Scoring_IF__c, KS_Scoring_Negocio__c, KS_Scoring_Actividad__c, KS_Coordinador__c, KS_Recurrencia__c, KS_Estado_Avisos_autom_ticos__c
                          FROM KS_Organizacion_Cliente__c
                          WHERE KS_Cliente_Distribucion__c = :cuenta.ID
                          AND KS_Cliente_Dest_Mercancias__c = :cuenta.ID
                          AND KS_Cliente_solicitante__c = :cuenta.ID];
            } else {
                
                marcas = [SELECT ID, Name, KS_Organizacion_de_ventas__c, KS_Lista_de_precios__c,
                          KS_Canal_de_distribucion__c, KS_Sector_Distribuidor__c,
                          KS_Area__c, KS_Delegacion__c, KS_Zona__c,
                          KS_Scoring_IF__c, KS_Scoring_Negocio__c, KS_Scoring_Actividad__c, KS_Coordinador__c, KS_Recurrencia__c, KS_Estado_Avisos_autom_ticos__c
                          FROM KS_Organizacion_Cliente__c
                          WHERE KS_Cliente_solicitante__c = :cuenta.ID];
            }

            System.debug('-- JCAR ---------------------------------- - KS_MarcasCliente_Controller.marcas? ' + marcas.size() + ' - ' + marcas);
            
            condiciones = new List<CondicionComercial>();
            List<KS_Condicion_Comercial__c> ccLst =  [SELECT ID, KS_Condicion__c, KS_Organizacion_Ventas__c, KS_Canal__c, KS_Sector__c, 
                                                      KS_Familia__c, KS_Serie_single__c, KS_Subserie__c, KS_Tarifa__c, KS_Importe__c, KS_Porcentaje__c 
                                                      FROM KS_Condicion_Comercial__c WHERE KS_Cliente_Jerarquia__c = :cuenta.ID];
            for (KS_Condicion_Comercial__c cc : ccLst) {
                
                CondicionComercial ccN = new CondicionComercial(cc);
                condiciones.add(ccN);
            }
            
            System.debug('-- JCAR ---------------------------------- - KS_MarcasCliente_Controller.condiciones? ' + condiciones.size() + ' - ' + condiciones);
        }        
    }
    
    public class CondicionComercial {
        
        public String condicion {get;set;}
        public String orgVentas {get;set;}
        public String canal {get;set;}
        public String sector {get;set;}
        public String tarifa {get;set;}
        public String familia {get;set;}
        public String serie {get;set;}
        public String subserie {get;set;}
        public Decimal importe {get;set;}
        public Decimal porcentaje {get;set;}
        
        public CondicionComercial(KS_Condicion_Comercial__c cc) {
             
            condicion = cc.KS_Condicion__c;
            orgVentas = cc.KS_Organizacion_Ventas__c;
            canal = cc.KS_Canal__c;
            sector = cc.KS_Sector__c;
            tarifa = cc.KS_Tarifa__c;
            familia = cc.KS_Familia__c;
            serie = cc.KS_Serie_single__c;
            subserie = cc.KS_Subserie__c;
            importe = cc.KS_Importe__c;
            porcentaje = cc.KS_Porcentaje__c;
        }
    }
    
}