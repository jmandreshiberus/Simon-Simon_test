trigger KS_Opportunity_Trigger on Opportunity (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    
    KS_Opportunity_Trigger opT = new KS_Opportunity_Trigger(trigger.isAfter, trigger.isBefore, trigger.isDelete, trigger.isInsert, trigger.isUnDelete, 
            trigger.isUpdate, trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
            
    opT.run();
}