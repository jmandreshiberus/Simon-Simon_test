@isTest
private class KS_TEST_MergeTool_MergeAuto
{
	@testSetUp
	static void DataSetUp()
	{
        KS_Trigger_Test.disableTrigger();
		KS_TEST_FUNCTIONS func  = new KS_TEST_FUNCTIONS();
		Map<String, ID> rd = KS_TEST_FUNCTIONS.getRecordTypeStatic();
		Account acc = func.createAccDistribuidor(rd);
		//Accounts de merge
		Account acc2 = new Account();
        ID rt = rd.get('KS_Distribuidores_SAP');
        acc2.RecordTypeId = rt;
        
        acc2.Name = 'Test Cuenta2';
        acc2.KS_Id_SAP__c = 'IDSAPTEST1232';
        acc2.Phone = '666666662';
        acc2.BillingCountryCode = 'ES';
        acc2.BillingCity = 'Barcelona';
        acc2.BillingPostalCode = '08907';
        acc2.BillingStreet = 'Calle de gracia';
        acc2.KS_Grupo_de_ctas_deudor__c = '0001';
        acc2.KS_Idioma__c = 'ES';
        acc2.KS_Nombre_2__c = 'Cliente Distribuidor TEST2';
        acc2.KS_N_identificacion_fiscal_suplementario__c = '1';
        acc2.KS_Numero_de_identificacion_fiscal_1__c = '1';
        acc2.KS_N_de_telefono_2__c = '1';
        acc2.KS_Actividad__c = 'Distribuidor';
        acc2.KS_Canal__c = 'Distribuidores SAP';
		insert acc2;

		Account acc3 = new Account();
        acc3.RecordTypeId = rt;
        
        acc3.Name = 'Test Cuenta3';
        acc3.KS_Id_SAP__c = 'IDSAPTEST123';
        acc3.Phone = '66666666';
        acc3.BillingCountryCode = 'ES';
        acc3.BillingCity = 'Barcelona';
        acc3.BillingPostalCode = '08907';
        acc3.BillingStreet = 'Calle de gracia';
        acc3.KS_Grupo_de_ctas_deudor__c = '0001';
        acc3.KS_Idioma__c = 'ES';
        acc3.KS_Nombre_2__c = 'Cliente Distribuidor TEST23';
        acc3.KS_N_identificacion_fiscal_suplementario__c = '1';
        acc3.KS_Numero_de_identificacion_fiscal_1__c = '1';
        acc3.KS_N_de_telefono_2__c = '1';
        acc3.KS_Actividad__c = 'Distribuidor';
        acc3.KS_Canal__c = 'Distribuidores SAP';
		insert acc3;


		//Contactos para borrar
		Contact c1 = func.createContact(acc);
		Contact c2 = new Contact();
		c2.AccountId = acc.id;
        c2.Salutation = 'Sr.';
		c2.FirstName = 'Pruebo2';
        c2.LastName = 'Testeo';
		insert c2;

		Contact c3 = new Contact();
		c3.AccountId = acc.id;
        c3.Salutation = 'Sr.';
		c3.FirstName = 'Pruebo3';
        c3.LastName = 'Testez3';
		insert c3;

		//Contactos que darán error. 
		Contact c4 = new Contact();
		c4.AccountId = acc.id;
        c4.Salutation = 'Sr.';
		c4.FirstName = 'Pruebo4';
        c4.LastName = 'Testez4';
		insert c4;

		//Contactos que se fusionan
		Contact fusion1 = new Contact();
		fusion1.AccountId = acc.id;
        fusion1.Salutation = 'Sr.';
		fusion1.FirstName = 'fusion1';
        fusion1.LastName = 'Testeo';
		insert fusion1;
		Contact fusion2 = new Contact();
		fusion2.AccountId = acc.id;
        fusion2.Salutation = 'Sr.';
		fusion2.FirstName = 'fusion2';
        fusion2.LastName = 'Testeo';
		insert fusion2;
		Contact fusion3 = new Contact();
		fusion3.AccountId = acc.id;
        fusion3.Salutation = 'Sr.';
		fusion3.FirstName = 'fusion3';
        fusion3.LastName = 'Testeo';
		insert fusion3;
		
		KS_Estructura_Geografica__c geo = func.createEstructuraGeografica(acc);
		KS_Organizacion_Cliente__c orgAcc = func.createAccDistribuidorOrganizacion(acc, geo);
		KS_Obra__c obra = func.createObra(rd);
		Pricebook2 pbS = func.createPricebook();
		Opportunity oferta = func.createOferta(acc, orgAcc, obra,pbS);
		func.createOfertaPendiente(oferta);
		func.createTaskforContact(c4);
		func.createEventforContact(c4);
		func.createReporteforContact(c4);
		func.createIntervinientesforContact(c4,obra,acc);

		List<KS_Fusion__c> fusionLSt = new List<KS_Fusion__c>();
		KS_Fusion__c fu1 = new KS_Fusion__c();
		fu1.KS_Id_Principal__c = c1.Id;
		fu1.KS_Accion__c = 'DELETE';
		fusionLSt.add(fu1);
		KS_Fusion__c fu2 = new KS_Fusion__c();
		fu2.KS_Id_Principal__c = c2.Id;
		fu2.KS_Accion__c = 'DELETE';
		fusionLSt.add(fu2);
		KS_Fusion__c fu3 = new KS_Fusion__c();
		fu3.KS_Id_Principal__c = c3.Id;
		fu3.KS_Accion__c = 'DELETE';
		fusionLSt.add(fu3);
		KS_Fusion__c fu4 = new KS_Fusion__c();
		fu4.KS_Id_Principal__c = c4.Id;
		fu4.KS_Accion__c = 'DELETE';
		fusionLSt.add(fu4);

		//Fusion ok
		KS_Fusion__c fusionCn = new KS_Fusion__c();
		fusionCn.KS_Id_Principal__c = fusion1.Id;
		fusionCn.KS_Id_Duplicado__c = fusion2.Id;
		fusionCn.KS_Id_Duplicado_2__c = fusion3.Id;
		fusionCn.KS_Ctc_Calle__c = 'Calle';
		fusionCn.KS_Ctc_Cargo__c = 'Cargo';
		fusionCn.KS_Ctc_Ciudad__c = 'Madrid';
		fusionCn.KS_Ctc_Codigo_Postal__c = '28039';
		fusionCn.KS_Ctc_Correo__c = 'correo@correo.com';
		fusionCn.KS_Ctc_Estado_Provincia__c = 'Madrid';
		fusionCn.KS_Ctc_Funcion_en_empresa__c = 'Compras';
		fusionCn.KS_Ctc_Idioma__c = 'ES';
		fusionCn.KS_Ctc_Movil__c = '666666666';
		fusionCn.KS_Ctc_Pais__c = 'España';
		fusionCn.KS_Ctc_Telefono__c = '123456789';
		fusionCn.KS_Ctc_Telefono_Particular__c = '123456789';
		fusionCn.KS_Accion__c = 'MERGE';
		fusionCn.KS_Tipo__c = 'CONTACT';
		fusionLSt.add(fusionCn);

		//Fusion Accounts
		KS_Fusion__c fusionAcc = new KS_Fusion__c();
		fusionAcc.KS_Id_Principal__c = acc.Id;
		fusionAcc.KS_Id_Duplicado__c = acc2.Id;
		fusionAcc.KS_Id_Duplicado_2__c = acc3.Id;
		fusionAcc.KS_Acc_Actividad__c = 'Distribuidor';
		fusionAcc.KS_Acc_Calle__c = 'Calle';
		fusionAcc.KS_Acc_Canal__c = 'Distribuidores SAP';
		fusionAcc.KS_Acc_Ciudad__c = 'Madrid';
		fusionAcc.KS_Acc_Codigo_Postal__c = '28039';
		fusionAcc.KS_Acc_Correo__c= 'correo@correo.com';
		fusionAcc.KS_Acc_Estado_Provincia__c = 'Madrid';
		fusionAcc.KS_Acc_Pais__c = 'España';
		fusionAcc.KS_Acc_Sector__c = 'Residencial';
		fusionAcc.KS_Acc_Subactividad__c = 'Eléctrico';
		fusionAcc.KS_Acc_Telefono_2__c = '123456789';
		fusionAcc.KS_Acc_Telefono_3__c = '123456780';
		fusionAcc.KS_Acc_Telefono__c = '012345678';
		fusionAcc.KS_Accion__c = 'MERGE';
		fusionAcc.KS_Tipo__c = 'ACCOUNT';
		
		fusionLSt.add(fusionAcc);
		insert fusionLSt;
        KS_Trigger_Test.enableTrigger();

	}
	@isTest
	static void itShould_DeleteContacts()
	{
		KS_Batch_MergeTool_DeleteContacts del = new KS_Batch_MergeTool_DeleteContacts();
        ID batchprocessid = Database.executeBatch(del);
	}
	@isTest
	static void itShould_MergeContacts()
	{
		KS_Batch_MergeTool_MergeContacts mrgCn = new KS_Batch_MergeTool_MergeContacts();
        ID batchprocessid = Database.executeBatch(mrgCn);
	}
	@isTest
	static void itShould_MergeAccounts()
	{
		KS_Batch_MergeTool_MergeAccounts mrgAcc = new KS_Batch_MergeTool_MergeAccounts();
        ID batchprocessid = Database.executeBatch(mrgAcc);
	}
}