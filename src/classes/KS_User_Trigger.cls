public class KS_User_Trigger extends KS_TriggerController {

    public KS_User_Trigger (Boolean isAfter, Boolean isBefore, Boolean isDelete, Boolean isInsert, Boolean isUndelete, Boolean isUpdate,
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
        
        List<User> users = (List<User>)lstNewItems;
        for (User usr : users) {
            usr.KS_Language__c = usr.LanguageLocaleKey;
        }
    }
}