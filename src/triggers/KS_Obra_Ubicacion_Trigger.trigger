trigger KS_Obra_Ubicacion_Trigger on KS_Obra_Ubicacion__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    
    KS_Obra_Ubicacion_Trigger out = new KS_Obra_Ubicacion_Trigger(trigger.isAfter, trigger.isBefore, trigger.isDelete, trigger.isInsert, trigger.isUnDelete, 
            trigger.isUpdate, trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
            
    out.run();
}