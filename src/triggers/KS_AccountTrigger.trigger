trigger KS_AccountTrigger on Account (after delete, after insert, after undelete, after update, before delete, before insert, before update) {

    KS_AccountTrigger accT = new KS_AccountTrigger(trigger.isAfter, trigger.isBefore, trigger.isDelete, trigger.isInsert, trigger.isUnDelete, 
            trigger.isUpdate, trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
    accT.run();
}