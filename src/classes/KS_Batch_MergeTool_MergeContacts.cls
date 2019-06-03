global class KS_Batch_MergeTool_MergeContacts implements Database.Batchable<sObject> {
	
	String query = 'SELECT Id, Name, KS_Accion__c, KS_Id_Principal__c, KS_Id_Duplicado__c, KS_Id_Duplicado_2__c, KS_Ctc_Calle__c, KS_Ctc_Ciudad__c, KS_Ctc_Codigo_Postal__c, KS_Ctc_Estado_Provincia__c, KS_Ctc_Pais__c, KS_Ctc_Telefono__c, KS_Ctc_Movil__c, KS_Ctc_Telefono_Particular__c, KS_Ctc_Correo__c, KS_Ctc_Funcion_en_empresa__c, KS_Ctc_Cargo__c, KS_Ctc_Idioma__c FROM KS_Fusion__c WHERE KS_Accion__c = \'MERGE\' AND KS_Tipo__c = \'CONTACT\'';
	
	global KS_Batch_MergeTool_MergeContacts() {
		
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) 
	{
		KS_MergeTool_MergeAuto mergeCn = new KS_MergeTool_MergeAuto();
        System.debug('-- JCAR -- KS_Batch_MergeTool_MergeContacts ----------------- scope ' 
                     + scope.size() + ' List<sObject> ' + scope);
		mergeCn.MergeContacts(scope);
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}