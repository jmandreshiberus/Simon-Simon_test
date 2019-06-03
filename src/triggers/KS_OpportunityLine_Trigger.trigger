trigger KS_OpportunityLine_Trigger on OpportunityLineItem (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    
    KS_OpportunityLine_Trigger pot = new KS_OpportunityLine_Trigger(trigger.isAfter, trigger.isBefore, trigger.isDelete, trigger.isInsert, trigger.isUnDelete, 
            trigger.isUpdate, trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
            
    pot.run();
}