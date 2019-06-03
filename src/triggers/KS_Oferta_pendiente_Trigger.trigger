trigger KS_Oferta_pendiente_Trigger on KS_Oferta_pendiente__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    
    KS_Oferta_pendiente_Trigger opt = new KS_Oferta_pendiente_Trigger(trigger.isAfter, trigger.isBefore, trigger.isDelete, trigger.isInsert, trigger.isUnDelete, 
            trigger.isUpdate, trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
            
    opt.run();
}