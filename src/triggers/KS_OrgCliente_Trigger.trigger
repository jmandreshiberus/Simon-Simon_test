trigger KS_OrgCliente_Trigger on KS_Organizacion_Cliente__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    
    KS_OrgCliente_Trigger ocT = new KS_OrgCliente_Trigger(trigger.isAfter, trigger.isBefore, trigger.isDelete, trigger.isInsert, trigger.isUnDelete, 
            trigger.isUpdate, trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
            
    ocT.run();
}