global class KS_Batch_MergeTool_DeleteContacts implements Database.Batchable<sObject> {
	
	String query = 'SELECT Id,KS_Id_Principal__c,KS_Accion__c FROM KS_Fusion__c WHERE KS_Accion__c = \'DELETE\'';
	
	global KS_Batch_MergeTool_DeleteContacts() {
		
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<KS_Fusion__c> scope) 
	{
		KS_MergeTool_MergeAuto mergeDelCn = new KS_MergeTool_MergeAuto();
        System.debug('-- JCAR -- KS_Batch_MergeTool_DeleteContacts ----------------- scope ' 
                     + scope.size() + ' List<sObject> ' + scope);
		mergeDelCn.DeleteContacts(scope);
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
}