trigger KS_ContactTrigger on Contact (after delete, after insert, after undelete, after update, before delete, before insert, before update) {

    KS_ContactTrigger conTrigger = new KS_ContactTrigger(trigger.isAfter, trigger.isBefore, trigger.isDelete, trigger.isInsert, trigger.isUnDelete, 
            trigger.isUpdate, trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
            
    conTrigger.run();

}