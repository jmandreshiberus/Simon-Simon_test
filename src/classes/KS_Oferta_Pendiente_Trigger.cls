public without sharing class KS_Oferta_Pendiente_Trigger extends KS_TriggerController {

    public KS_Oferta_Pendiente_Trigger (Boolean isAfter, Boolean isBefore, Boolean isDelete, Boolean isInsert, Boolean isUndelete, Boolean isUpdate,
        List<sObject> lstNewItems, Map<Id, sObject> mapNewItems, List<sObject> lstOldItems, Map<Id, sObject> mapOldItems)
    {
        super(isAfter, isBefore, isDelete, isInsert, isUndelete, isUpdate, lstNewItems, mapNewItems, lstOldItems, mapOldItems);
    }
    
    public static Boolean blocked() { System.debug('-- TRIGGER BLOCKED! --'); return Test.isRunningTest() && KS_Trigger_Test.blockTrigger; }
    
    protected override void  runBeforeInsert(){ if(blocked()){return;} executeBeforeInsert(); }
    protected override void  runBeforeUpdate(){ if(blocked()){return;} executeBeforeUpdate(); }    
    public void executeBeforeInsert() { executeBeforeUpsert(); }
    public void executeBeforeUpdate() { executeBeforeUpsert(); }    
    
    protected override void  runAfterInsert(){ executeAfterInsert(); }
    protected override void  runAfterUpdate(){ executeAfterUpdate(); }    
    public void executeAfterInsert() { executeAfterUpsert(); }
    public void executeAfterUpdate() { executeAfterUpsert(); }
    
    public void executeBeforeUpsert() {
        
        List<KS_Oferta_Pendiente__c> oppLst = (List<KS_Oferta_Pendiente__c>)lstNewItems;

        List<ID> idOferta = new List<ID>(); Map<ID,ID> idObra = new Map<ID,ID>();
        for (KS_Oferta_Pendiente__c opp : oppLst) {
            idOferta.add(opp.KS_Oferta__c);
        }
        
        List<Opportunity> ofertas = new List<Opportunity>();
        for (Opportunity opp : [SELECT ID,KS_Obra__C FROM Opportunity WHERE ID IN:idOferta]) {
            if (opp.KS_Obra__c != null) {
                idObra.put(opp.ID,opp.KS_Obra__c);
            }
            ofertas.add(opp);
        }
        
        for (KS_Oferta_Pendiente__c opp : oppLst) {
            
            if (idObra.containsKey(opp.KS_Oferta__c)) {
                opp.KS_Obra__c = idObra.get(opp.KS_Oferta__c);
            }
        }
        
        System.Approval.unlock(ofertas, true);
    }
    
    public void executeAfterUpsert() {

        List<KS_Oferta_Pendiente__c> oppLst = (List<KS_Oferta_Pendiente__c>)lstNewItems;
		List<Opportunity> ofertas = new List<Opportunity>();
        
        List<ID> idObra = new List<ID>(); List<ID> idOferta = new List<ID>();
        for (KS_Oferta_Pendiente__c opp : oppLst) { 
            
            if (opp.KS_Obra__c != null) {
                idObra.add(opp.KS_Obra__c);
            }
            idOferta.add(opp.KS_Oferta__c);
        }
        for (ID idOf : idOferta) {
            Opportunity ofer = new Opportunity(); ofer.ID = idOf;
            ofertas.add(ofer);
        }
        
        System.Approval.lock(ofertas, true);
        KS_Opportunity_Trigger_Utility.calculaIntervinientes(idObra);
    }
}