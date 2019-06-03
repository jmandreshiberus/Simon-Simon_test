global class KS_Batch_MergeTool_MergeAccounts implements Database.Batchable<sObject> {
	
	String query = 'SELECT Id, Name, KS_Accion__c, KS_Id_Principal__c, KS_Id_Duplicado__c, KS_Id_Duplicado_2__c, KS_Force_Merge__c,KS_Acc_Calle__c, KS_Acc_Ciudad__c, KS_Acc_Codigo_Postal__c, KS_Acc_Estado_Provincia__c, KS_Acc_Pais__c, KS_Acc_Telefono__c, KS_Acc_Telefono_2__c, KS_Acc_Telefono_3__c, KS_Acc_Correo__c, KS_Acc_Canal__c, KS_Acc_Actividad__c, KS_Acc_Subactividad__c, KS_Acc_Sector__c FROM KS_Fusion__c WHERE KS_Accion__c = \'MERGE\' AND KS_Tipo__c = \'ACCOUNT\'';
	
	global KS_Batch_MergeTool_MergeAccounts() {
		
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) 
	{
        KS_MergeTool_MergeAuto mergeAcc = new KS_MergeTool_MergeAuto();
        System.debug('-- JCAR -- KS_Batch_MergeTool_MergeAccounts ----------------- scope ' 
                     + scope.size() + ' List<sObject> ' + scope);
		mergeAcc.MergeAccounts(scope);
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}