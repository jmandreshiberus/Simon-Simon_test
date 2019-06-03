trigger KS_User_Trigger on User (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    
    KS_User_Trigger ut = new KS_User_Trigger(trigger.isAfter, trigger.isBefore, trigger.isDelete, trigger.isInsert, trigger.isUnDelete, 
            trigger.isUpdate, trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
            
    ut.run();
}