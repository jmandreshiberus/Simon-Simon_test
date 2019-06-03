public without sharing class KS_Obra_Ubicacion_Trigger extends KS_TriggerController {

    public KS_Obra_Ubicacion_Trigger (Boolean isAfter, Boolean isBefore, Boolean isDelete, Boolean isInsert, Boolean isUndelete, Boolean isUpdate,
        List<sObject> lstNewItems, Map<Id, sObject> mapNewItems, List<sObject> lstOldItems, Map<Id, sObject> mapOldItems)
    {
        super(isAfter, isBefore, isDelete, isInsert, isUndelete, isUpdate, lstNewItems, mapNewItems, lstOldItems, mapOldItems);
    }
    
    public static Boolean blocked() { System.debug('-- TRIGGER BLOCKED! --'); return Test.isRunningTest() && KS_Trigger_Test.blockTrigger; }
    
    protected override void  runBeforeInsert(){ if(blocked()){return;} executeBeforeInsert(); }
    protected override void  runBeforeUpdate(){ if(blocked()){return;} executeBeforeUpdate(); }    
    public void executeBeforeInsert() { executeBeforeUpsert(); }
    public void executeBeforeUpdate() { executeBeforeUpsert(); } 

    public void executeBeforeUpsert() {
        
        List<KS_Obra_Ubicacion__c> ouLst = (List<KS_Obra_Ubicacion__c>)lstNewItems;
        for (KS_Obra_Ubicacion__c ou : ouLst) {
            
            if (ou.KS_MarcaF__c != null) { ou.KS_Marca__c = ou.KS_MarcaF__c; }
            if (ou.KS_AreaF__c != null) { ou.KS_Area__c = ou.KS_AreaF__c; }
            if (ou.KS_DelegacionF__c != null) { ou.KS_Delegacion__c = ou.KS_DelegacionF__c; }
            if (ou.KS_ZonaF__c != null) { ou.KS_Zona__c = ou.KS_ZonaF__c; }
        }
    }
}