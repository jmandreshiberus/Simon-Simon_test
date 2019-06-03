public without sharing class KS_ContactTrigger extends KS_TriggerController {
 
    public KS_ContactTrigger (Boolean isAfter, Boolean isBefore, Boolean isDelete, Boolean isInsert, Boolean isUndelete, Boolean isUpdate,
            List<sObject> lstNewItems, Map<Id, sObject> mapNewItems, List<sObject> lstOldItems, Map<Id, sObject> mapOldItems)
    {
        super(isAfter, isBefore, isDelete, isInsert, isUndelete, isUpdate, lstNewItems, mapNewItems, lstOldItems, mapOldItems);                 
    }
        
    public static Map<Id, sObject> conInUse = new Map<Id, sObject>();
    
    /**
     * TriggerControllers
     */
    
    protected override void runBeforeInsert(){
        
    }
    
    protected override void runAfterInsert(){
        executeNormalizacion();
    }
    
    protected override void runBeforeUpdate(){
         executeBeforeUpdate();
    }    
    
    protected override void runAfterUpdate(){
        executeNormalizacion();
    }
    
    protected override void  runBeforeDelete(){
        
    }
    
    
    /**
     * Execute Triggers
     */
     
    ///////////////
    /// UPDATE ///    
        
    //Cuando se modifique el campo Cuenta, se crea una linea Historico Laboral
    public void executeBeforeUpdate() { 
        
        return;
        
        List<Contact> lstNewItem = (List<Contact>)lstNewItems;
        Map<Id, Contact> mapOldItem = (Map<Id, Contact>)mapOldItems;
        List<Contact> lstContactMod = new List<Contact>();        
System.debug('-------------------------------------- SERG - _Historial_Laboral__c - lstNewItem: ' + lstNewItem);            
        for(Contact con : lstNewItem) {
            if(con.AccountId!=mapOldItem.get(con.Id).AccountId) 
                lstContactMod.add(con);
        }
        
        //Si hay contactos con el campo Account modificado 
        if(lstContactMod.size()>0) {
            List<KS_Historial_Laboral__c> lstHL = new List<KS_Historial_Laboral__c>();
System.debug('-------------------------------------- SERG - _Historial_Laboral__c ');            
            //Buscamos el ultimo historial de cada contacto
            List<AggregateResult> lstAgrRes = [ select KS_contacto__c, max(KS_Fecha_de_fin__c) KS_Fecha_de_fin__c from KS_Historial_Laboral__c where KS_Contacto__c in :lstContactMod group by KS_contacto__c ];     
System.debug('-------------------------------------- SERG - _Historial_Laboral__c - lstAgrRes : ' + lstAgrRes  );               
            for(Contact con : lstContactMod) {
                KS_Historial_Laboral__c hl = new KS_Historial_Laboral__c();
                hl.KS_Contacto__c = con.Id;
                hl.KS_Empresa__c = mapOldItem.get(con.Id).AccountId;
                hl.KS_Fecha_de_fin__c = Date.Today().addDays(-1);
                hl.KS_Fecha_de_inicio__c = Date.ValueOf(con.createddate);
                
                for(AggregateResult ar : lstAgrRes) {
                    String conID = String.ValueOf(ar.get('KS_contacto__c'));
                    Date fechaFin = Date.ValueOf(ar.get('expr0'));
                    
                    if(con.ID==conID) {                                            
                        hl.KS_Fecha_de_inicio__c = fechaFin.addDays(1);
                    }
                }
                lstHL.add(hl);
            }
System.debug('-------------------------------------- SERG - _Historial_Laboral__c - lstHL: ' + lstHL);             
            insert lstHL;
        }
    }
    
    public void executeNormalizacion() {
        System.debug('-------------------------JCAR - mapNewItems - ' + mapNewItems);
        System.debug('-------------------------JCAR - conInUse - ' + conInUse);
        if (conInUse.isEmpty()) {
            
            if (!KS_Normalizacion_Utils.getConfigurationFlag('NormalizacionContactoStatus')) {return;}
            
            mapNewItems = mapNewItems != null ? mapNewItems : new Map<ID,sObject>();
            conInUse = conInUse != null ? conInUse : new Map<ID,sObject>();
            for (ID key : mapNewItems.keySet()) { conInUse.put(key,mapNewItems.get(key)); }
            KS_Normalizacion_Utils.executeNormalizacion(Contact.class.getName(), lstNewItems);
        }
    }
}