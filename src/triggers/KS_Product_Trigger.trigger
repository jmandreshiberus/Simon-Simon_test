trigger KS_Product_Trigger on Product2 (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    
    KS_Product_Trigger pt = new KS_Product_Trigger(trigger.isAfter, trigger.isBefore, trigger.isDelete, trigger.isInsert, trigger.isUnDelete, 
            trigger.isUpdate, trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
            
    pt.run();
}